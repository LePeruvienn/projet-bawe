use sqlx::{PgPool, Row};
use axum::{Json, extract::State};
use axum::http::StatusCode;

use crate::models::auth::{LoginRequest, TokenResponse};
use crate::auth::token_handler::create_jwt;

/*
 * Try to log user with username and password
 * @auth {None} - no authorization needed
 */
pub async fn login(State(pool): State<PgPool>, Json(payload): Json<LoginRequest>) -> Result<Json<TokenResponse>, StatusCode> {

    println!("Loggin ...");

    let username = payload.username;
    let password = payload.password;

    let query = sqlx::query("SELECT id, username, password, is_admin FROM users WHERE username = $1").bind(username);

    match query.fetch_one(&pool).await {

        Ok(row) => {

            // Get DB datas
            let db_id: i32 = row.get("id");
            let db_username: String = row.get("username");
            let db_password: String = row.get("password");
            let db_is_admin: bool = row.get("is_admin");

            // If password matches, create token and return it
            if password == db_password {

                println!("Passwords matchs ! Creating Token with {db_username}");

                let token = create_jwt(db_id, db_username, db_is_admin);

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
