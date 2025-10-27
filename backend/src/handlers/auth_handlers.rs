use sqlx::{PgPool, Row};
use axum::{Json, extract::State};
use axum::http::StatusCode;

use crate::models::auth::{LoginRequest, TokenResponse};
use crate::auth::token_handler::create_jwt;

async fn login(State(pool): State<PgPool>, Json(payload): Json<LoginRequest>) -> Result<Json<TokenResponse>, StatusCode> {

    let username = payload.username;
    let password = payload.password;

    let query = sqlx::query("SELECT id, password FROM users WHERE email = $1").bind(username);

    match query.fetch_one(&pool).await {

        Ok(row) => {
            let user_id: i32 = row.get("id"); // Extract user ID
            let hashed_password: String = row.get("password"); // Extract hashed password

            // TODO: Code verify password method ! Its only compare two string right ???
            // (no we must also compare the signature but i dont know if iam gonna do this)
            if verify_password(&hashed_password, &password).unwrap_or(false) {

                // Create token if verification is successful
                let token = create_jwt(&user_id.to_string());

                return Ok(Json(TokenResponse { token }));
            }
        }
        Err(e) => {

            if let sqlx::Error::RowNotFound = e {

                // If no rows are found, return a specific error (like 204 No Content)
                return Err(StatusCode::NO_CONTENT);
            }

            // Handle other types of database errors
            return Err(StatusCode::INTERNAL_SERVER_ERROR);
        }
    }

    // If we reach here, the password verification failed or user not found
    Err(StatusCode::UNAUTHORIZED)
}

