use axum::{extract::{Path, State, Form}, Json, http::StatusCode};
use sqlx::PgPool;
use crate::models::user::User;
use crate::forms::user_forms::FormUser;

// Handler to greet a user by name from the path
pub async fn list_all(State(pool): State<PgPool>) -> Json<Vec<User>> {

    let query = sqlx::query_as::<_, User>("SELECT id, username, email, password, title, created_at FROM users");

    let users = query.fetch_all(&pool).await.unwrap();

    Json(users)
}

// Handler to greet a user by name from the path
pub async fn get_by_id(Path(id): Path<i32>, State(pool): State<PgPool>) -> Json<User> {

    let query = sqlx::query_as::<_, User>("SELECT id, username, email, password, title, created_at FROM users WHERE id = $1").bind(id);

    let user = query.fetch_one(&pool).await.unwrap();

    Json(user)
}

pub async fn create_user(Form(payload): Form<FormUser>, State(pool): State<PgPool>) -> Json<User> {

    let query = sqlx::query_as::<_, User>("INSERT INTO users (username, email, password, title)")
        .bind(&payload.username)
        .bind(&payload.email)
        .bind(&payload.password)
        .bind(&payload.title);

    let user = query.fetch_one(&pool).await.unwrap();

    Json(user)
}

/* TODO:
*
pub async fn delete_user(Path(id): Path<i32>, State(pool): State<PgPool>) -> StatusCode {

    let query = sqlx::query_as::<_, User>("DELETE FROM users WHERE id = $1;").bind(id);

    let resut = query.execute(&pool).await.unwrap();

    StatusCode::NO_CONTENT
}
*/
