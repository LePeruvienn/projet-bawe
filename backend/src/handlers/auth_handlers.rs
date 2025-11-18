use sqlx::{PgPool, Row};
use axum::{Json, extract::State};
use axum::http::StatusCode;
use argon2::{Argon2, PasswordVerifier, password_hash::PasswordHash};

use crate::models::auth::{AuthUser, LoginRequest, TokenResponse};
use crate::auth::token_handler::create_jwt;

/*
 * Try to log user with username and password
 * @auth {None} - no authorization needed
 */
pub async fn login(State(pool): State<PgPool>, Json(payload): Json<LoginRequest>) -> Result<Json<TokenResponse>, StatusCode> {

    let username = payload.username;
    let password = payload.password;

    let query = sqlx::query("SELECT id, password FROM users WHERE username = $1").bind(username);

    let result = query.fetch_one(&pool).await;

    match result {

        Ok(row) => {

            // Get DB datas
            let db_id: i32 = row.get("id");
            let db_password: String = row.get("password");

            // Verify if the hash is correct
            let parsed_hash = PasswordHash::new(&db_password)
                .map_err(|_| StatusCode::INTERNAL_SERVER_ERROR)?;

            // Check if hashed pasword is good
            if Argon2::default().verify_password(password.as_bytes(), &parsed_hash).is_ok() {

                let token = create_jwt(db_id);

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

/*
 * This function is used to ensure that user is admin in the DB
 * - This is not an hanlder, but an helper function
 */
pub async fn get_is_admin(pool: &PgPool, auth_user: &AuthUser) -> bool {

    // If user is not connected we can simply return false
    if !auth_user.is_connected {
        return false;
    }

    // Get user connected id
    let id = auth_user.user_id;

    // Get is_admin row in datbase for this user
    let query = sqlx::query("SELECT is_admin FROM users WHERE id = $1")
        .bind(id);

    // Execute query
    let result = query.fetch_one(pool).await;

    match result {

        // If we successfully fetch_one, we can return the is_admin row
        Ok(row) => {

            let is_admin: bool = row.get("is_admin");
            return is_admin;
        }

        // If there was an error in the fetch, print an error and return false
        Err(e) => {
            eprintln!("Error while check is_admin: {e}");
            return false;
        }
    }
}
