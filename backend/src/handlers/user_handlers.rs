use axum::{extract::{Path, Extension, State, Form, Query}, Json, http::StatusCode};
use argon2::{Argon2, PasswordHasher, password_hash::SaltString};
use rand::rngs::OsRng;
use sqlx::PgPool;

use crate::models::user::{User, FormCreateUser, FormUpdateUser};
use crate::models::auth::AuthUser;
use crate::handlers::{DEFAULT_LIMIT, DEFAULT_OFFSET, PaginationQuery};

/*
 * List all users data from database
 * @auth {Admin} - only for admin users
 */
pub async fn list(Extension(auth_user): Extension<AuthUser>, State(pool): State<PgPool>, Query(pagination): Query<PaginationQuery>) -> Result<Json<Vec<User>>, StatusCode> {

    // If user is not admin we return 401
    if !auth_user.is_admin {
        return Err(StatusCode::UNAUTHORIZED);
    }

    let limit = pagination.limit.unwrap_or(DEFAULT_LIMIT); 
    let offset = pagination.offset.unwrap_or(DEFAULT_OFFSET);

    let query = sqlx::query_as::<_, User>("
        SELECT id, username, email, title, created_at, is_admin FROM users
        ORDER BY created_at DESC
        LIMIT $1
        OFFSET $2;
    ")
    .bind(&limit)
    .bind(&offset);

    let users = query.fetch_all(&pool).await
        .map_err(|_| StatusCode::INTERNAL_SERVER_ERROR)?; // Return 500 if SQL request failed

    Ok(Json(users))
}

/*
 * List a specific user data from database
 * @auth {Admin} - only for admin users
 * @param {id} - target user id
 */
pub async fn get_by_id(Path(id): Path<i32>, Extension(auth_user): Extension<AuthUser>, State(pool): State<PgPool>) -> Result<Json<User>, StatusCode> {

    // If user is not admin we return 401
    if !auth_user.is_admin {
        return Err(StatusCode::UNAUTHORIZED);
    }

    let query = sqlx::query_as::<_, User>("SELECT id, username, email, title, created_at, is_admin FROM users WHERE id = $1").bind(id);

    let user = query.fetch_one(&pool).await
        .map_err(|_| StatusCode::INTERNAL_SERVER_ERROR)?; // Return 500 if SQL request failed

    Ok(Json(user))
}

/*
 * Create an new user in the database and returns it
 * @auth {None} - no authorization needed
 * @param {FormCreateUser} - form input data
 */
pub async fn create_user( Extension(auth_user): Extension<AuthUser>, State(pool): State<PgPool>, Form(payload): Form<FormCreateUser>) -> Result<Json<User>, StatusCode> {

    // If some is trying to create an admin user but is not admin return 401
    if payload.is_admin && !auth_user.is_admin{
        return Err(StatusCode::UNAUTHORIZED);
    }

    // Get password data
    let password = &payload.password;

    // Generate random seed
    let salt = SaltString::generate(&mut OsRng);

    // Hash password
    let password_hash = Argon2::default()
        .hash_password(password.as_bytes(), &salt)
        .map_err(|_| StatusCode::INTERNAL_SERVER_ERROR)?
        .to_string();

    let query = sqlx::query_as::<_, User>("
        INSERT INTO users (username, email, password, title, is_admin)
        VALUES ($1, $2, $3, $4, $5)
        RETURNING id, username, email, title, created_at, is_admin;
    ")
    .bind(&payload.username)
    .bind(&payload.email)
    .bind(&password_hash)
    .bind(&payload.title)
    .bind(&payload.is_admin);

    let user = query.fetch_one(&pool).await
        .map_err(|e| {
            eprintln!("Error creating user: {:?}", e);
            StatusCode::INTERNAL_SERVER_ERROR
        })?; // Return 500 if SQL request failed

    // Return the created user
    Ok(Json(user))
}

/*
 * Delete an user from the database
 * @auth {Admin} - only for admin users
 * @param {id} - user id you want to delete
 */
pub async fn delete_user(Path(id): Path<i32>, Extension(auth_user): Extension<AuthUser>, State(pool): State<PgPool>) -> StatusCode {

    // If user is not admin we return 401
    if !auth_user.is_admin {
        return StatusCode::UNAUTHORIZED;
    }

    let query = sqlx::query("DELETE FROM users WHERE id = $1;").bind(id);

    let result = query.execute(&pool).await;

    match result {

        Ok(res) if res.rows_affected() > 0 => StatusCode::NO_CONTENT, // Return 204 if success
        Ok(_) => StatusCode::NOT_FOUND, // Returns 404 if not user found
        Err(_) => StatusCode::INTERNAL_SERVER_ERROR, // Returns 500 if SQL error
    }
}

/*
 * Update an user from the database
 * @auth {Admin, Connected} - admin can modify all users data and users can only modify there own
 * @param {id} - user id you want to update
 * @param {FormUpdateUser} - form input data
 */
pub async fn update_user(Path(id): Path<i32>, Extension(auth_user): Extension<AuthUser>, State(pool): State<PgPool>, Form(payload): Form<FormUpdateUser>) -> StatusCode {

    let is_authorized = (auth_user.is_connected && auth_user.user_id == id) || auth_user.is_admin;

    // If user is not admin or is not connect on his account return 401
    if !is_authorized {
        return StatusCode::UNAUTHORIZED;
    }

    // If some is trying to set an user to admin but is not an admin return 401
    if payload.is_admin && !auth_user.is_admin{
        return StatusCode::UNAUTHORIZED;
    }

    // Check if a new password is provided in the payload
    if let Some(password) = payload.password {

        // Generate and Hash the password
        let salt = SaltString::generate(&mut OsRng);
        let password_hash = Argon2::default()
            .hash_password(password.as_bytes(), &salt)
            .map_err(|_| StatusCode::INTERNAL_SERVER_ERROR)
            .unwrap().to_string();

        // Create SQL query
        let query = sqlx::query("UPDATE users SET username = $1, email = $2, password = $3, title = $4, is_admin = $5 WHERE id = $6")
            .bind(&payload.username)
            .bind(&payload.email)
            .bind(&password_hash)
            .bind(&payload.title)
            .bind(&payload.is_admin)
            .bind(id);


        // Execute query
        let result = query.execute(&pool).await;

        match result {

            Ok(res) if res.rows_affected() > 0 => StatusCode::NO_CONTENT, // 204
            Ok(_) => StatusCode::NOT_FOUND, // 404
            Err(_) => StatusCode::INTERNAL_SERVER_ERROR, // 500
        }

    // If there is no password in the payload
    } else {

        // Create query
        let query = sqlx::query("UPDATE users SET username = $1, email = $2, title = $3, is_admin = $4 WHERE id = $5")
            .bind(&payload.username)
            .bind(&payload.email)
            .bind(&payload.title)
            .bind(&payload.is_admin)
            .bind(id);

        // Execute query
        let result = query.execute(&pool).await;

        match result {

            Ok(res) if res.rows_affected() > 0 => StatusCode::NO_CONTENT, // 204
            Ok(_) => StatusCode::NOT_FOUND, // 404
            Err(_) => StatusCode::INTERNAL_SERVER_ERROR, // 500
        }
    }
}
/*
 * Get connected user data
 * @auth {Connected} - only for connected users
 */
pub async fn get_connected(Extension(auth_user): Extension<AuthUser>, State(pool): State<PgPool>) -> Result<Json<User>, StatusCode> {

    println!("Trying to get connected user ...");

    // If user is not connected we return 401
    if !auth_user.is_connected {
        return Err(StatusCode::UNAUTHORIZED);
    }

    // Get connected user username
    let username = auth_user.username;

    println!("User is connected with {username}");

    let query = sqlx::query_as::<_, User>("SELECT id, username, email, title, created_at, is_admin FROM users WHERE username = $1")
        .bind(username);

    let user = query.fetch_one(&pool).await
        .map_err(|_| StatusCode::INTERNAL_SERVER_ERROR)?; // returns 500 if SQL error

    Ok(Json(user))
}
