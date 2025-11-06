use axum::{extract::{Path, Extension, State, Form}, Json, http::StatusCode};
use sqlx::PgPool;
use crate::models::user::{User, FormUser};
use crate::models::auth::AuthUser;


pub async fn list_all(State(pool): State<PgPool>) -> Result<Json<Vec<User>>, StatusCode> {

    let query = sqlx::query_as::<_, User>("SELECT id, username, email, password, title, created_at, is_admin FROM users");

    let users = query.fetch_all(&pool).await
        .map_err(|_| StatusCode::INTERNAL_SERVER_ERROR)?; // retourne 500 si erreur SQL
    //
    Ok(Json(users))
}

pub async fn get_by_id(Path(id): Path<i32>, State(pool): State<PgPool>) -> Result<Json<User>, StatusCode> {

    let query = sqlx::query_as::<_, User>("SELECT id, username, email, password, title, created_at, is_admin FROM users WHERE id = $1").bind(id);

    let user = query.fetch_one(&pool).await
        .map_err(|_| StatusCode::INTERNAL_SERVER_ERROR)?; // retourne 500 si erreur SQL

    Ok(Json(user))
}

pub async fn create_user(State(pool): State<PgPool>, Form(payload): Form<FormUser>) -> StatusCode {

    let query = sqlx::query("INSERT INTO users (username, email, password, title, is_admin) VALUES ($1, $2, $3, $4, $5);")
        .bind(&payload.username)
        .bind(&payload.email)
        .bind(&payload.password)
        .bind(&payload.title)
        .bind(&payload.is_admin);

    let result = query.execute(&pool).await;

    match result {

        Ok(_) => StatusCode::CREATED, // 201
        Err(_) => StatusCode::INTERNAL_SERVER_ERROR // erreur SQL
    }
}

pub async fn delete_user(Path(id): Path<i32>, State(pool): State<PgPool>) -> StatusCode {

    let query = sqlx::query("DELETE FROM users WHERE id = $1;").bind(id);

    let result = query.execute(&pool).await;

    match result {

        Ok(res) if res.rows_affected() > 0 => StatusCode::NO_CONTENT, // 204
        Ok(_) => StatusCode::NOT_FOUND, // aucun utilisateur supprimé
        Err(_) => StatusCode::INTERNAL_SERVER_ERROR, // erreur SQL
    }
}

pub async fn update_user(Path(id): Path<i32>, State(pool): State<PgPool>, Form(payload): Form<FormUser>) -> StatusCode {

    let query = sqlx::query("UPDATE users SET username = $1, email = $2, password = $3, title = $4 WHERE id = $5")
        .bind(&payload.username)
        .bind(&payload.email)
        .bind(&payload.password)
        .bind(&payload.title)
        .bind(id);

    let result = query.execute(&pool).await;

    match result {

        Ok(res) if res.rows_affected() > 0 => StatusCode::NO_CONTENT, // 204
        Ok(_) => StatusCode::NOT_FOUND, // aucun utilisateur mis à jour
        Err(_) => StatusCode::INTERNAL_SERVER_ERROR, // erreur SQL
    }
}

pub async fn get_connected(Extension(auth_user): Extension<AuthUser>, State(pool): State<PgPool>) -> Result<Json<User>, StatusCode> {

    println!("Trying to get connected user ...");

    // If user is not connected we return UNAUTHORIZED
    if !auth_user.is_connected {
        return Err(StatusCode::UNAUTHORIZED);
    }

    let username = auth_user.username;

    println!("User is connected with {username}");

    // Prepare query with auth_user username
    let query = sqlx::query_as::<_, User>("SELECT id, username, email, password, title, created_at, is_admin FROM users WHERE username = $1")
        .bind(username);

    // Run query and map it as User struct
    let user = query.fetch_one(&pool).await
        .map_err(|_| StatusCode::INTERNAL_SERVER_ERROR)?; // retourne 500 si erreur SQL

    Ok(Json(user))
}
