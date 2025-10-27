use sqlx::{PgPool, Row};
use axum::{Json, extract::State};
use axum::http::StatusCode;

use crate::models::auth::{LoginRequest, TokenResponse};
use crate::auth::token_handler::create_jwt;

pub async fn login(State(pool): State<PgPool>, Json(payload): Json<LoginRequest>) -> Result<Json<TokenResponse>, StatusCode> {

    print!("Loggin ...");

    let username = payload.username;
    let password = payload.password;

    let query = sqlx::query("SELECT id, password FROM users WHERE username = $1").bind(username);

    match query.fetch_one(&pool).await {

        Ok(row) => {

            let user_id: i32 = row.get("id");
            let db_password: String = row.get("password");

            if password == db_password {

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
