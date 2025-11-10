use axum::{extract::{Path, Extension, State, Form}, Json, http::StatusCode};
use sqlx::PgPool;
use crate::models::user::{User, FormUser};
use crate::models::auth::AuthUser;

/*
 * List all users data from database
 * @auth {Admin} - only for admin users
 */
pub async fn list_all(Extension(auth_user): Extension<AuthUser>, State(pool): State<PgPool>) -> Result<Json<Vec<User>>, StatusCode> {

    // If user is not admin we return 401
    if !auth_user.is_admin {
        return Err(StatusCode::UNAUTHORIZED);
    }

    let query = sqlx::query_as::<_, User>("SELECT id, username, email, password, title, created_at, is_admin FROM users");

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

    let query = sqlx::query_as::<_, User>("SELECT id, username, email, password, title, created_at, is_admin FROM users WHERE id = $1").bind(id);

    let user = query.fetch_one(&pool).await
        .map_err(|_| StatusCode::INTERNAL_SERVER_ERROR)?; // Return 500 if SQL request failed

    Ok(Json(user))
}

/*
 * List a specific user data from database
 * @auth {None} - no authorization needed
 * @param {FormUser} - form input data
 */
pub async fn create_user(State(pool): State<PgPool>, Form(payload): Form<FormUser>) -> StatusCode {

    let query = sqlx::query("INSERT INTO users (username, email, password, title, is_admin) VALUES ($1, $2, $3, $4, $5);")
        .bind(&payload.username)
        .bind(&payload.email)
        .bind(&payload.password)
        .bind(&payload.title)
        .bind(&payload.is_admin);

    let result = query.execute(&pool).await;

    match result {

        Ok(_) => StatusCode::CREATED, // Return 201 if user created successfully
        Err(_) => StatusCode::INTERNAL_SERVER_ERROR // Return 500 if SQL request failed
    }
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
 * @param {FormUser} - form input data
 */
pub async fn update_user(Path(id): Path<i32>, Extension(auth_user): Extension<AuthUser>, State(pool): State<PgPool>, Form(payload): Form<FormUser>) -> StatusCode {

    // If user is not connected or tries to modify an other account than his own, or is not admin,
    // Return 401
    if !(auth_user.is_connected && auth_user.user_id == id) || !auth_user.is_admin {
        return StatusCode::UNAUTHORIZED;
    }

    let query = sqlx::query("UPDATE users SET username = $1, email = $2, password = $3, title = $4 WHERE id = $5")
        .bind(&payload.username)
        .bind(&payload.email)
        .bind(&payload.password)
        .bind(&payload.title)
        .bind(id);

    let result = query.execute(&pool).await;

    match result {

        Ok(res) if res.rows_affected() > 0 => StatusCode::NO_CONTENT, // Returns 204 if sucess
        Ok(_) => StatusCode::NOT_FOUND, // Returns 404 if user not found
        Err(_) => StatusCode::INTERNAL_SERVER_ERROR, // Returns 500 if SQL error
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

    let query = sqlx::query_as::<_, User>("SELECT id, username, email, password, title, created_at, is_admin FROM users WHERE username = $1")
        .bind(username);

    let user = query.fetch_one(&pool).await
        .map_err(|_| StatusCode::INTERNAL_SERVER_ERROR)?; // returns 500 if SQL error

    Ok(Json(user))
}
