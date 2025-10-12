use axum::{extract::{Path, State, Form}, Json, http::StatusCode};
use sqlx::PgPool;
use crate::models::user::User;
use crate::forms::user_forms::FormUser;

// Handler to greet a user by name from the path
pub async fn list_all(State(pool): State<PgPool>) -> Result<Json<Vec<User>>, StatusCode> {

    let query = sqlx::query_as::<_, User>("SELECT id, username, email, password, title, created_at FROM users");

    let users = query.fetch_all(&pool).await
        .map_err(|_| StatusCode::INTERNAL_SERVER_ERROR)?; // retourne 500 si erreur SQL
    //
    Ok(Json(users))
}

// Handler to greet a user by name from the path
pub async fn get_by_id(Path(id): Path<i32>, State(pool): State<PgPool>) -> Result<Json<User>, StatusCode> {

    let query = sqlx::query_as::<_, User>("SELECT id, username, email, password, title, created_at FROM users WHERE id = $1").bind(id);

    let user = query.fetch_one(&pool).await
        .map_err(|_| StatusCode::INTERNAL_SERVER_ERROR)?; // retourne 500 si erreur SQL

    Ok(Json(user))
}

pub async fn create_user(State(pool): State<PgPool>, Form(payload): Form<FormUser>) -> StatusCode {

    let query = sqlx::query("INSERT INTO users (username, email, password, title)")
        .bind(&payload.username)
        .bind(&payload.email)
        .bind(&payload.password)
        .bind(&payload.title);

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
