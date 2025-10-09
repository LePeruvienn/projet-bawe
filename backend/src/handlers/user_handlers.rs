use axum::{extract::{Path, State}, Json};
use sqlx::PgPool;
use crate::models::user::User;

// Handler to greet a user by name from the path
pub async fn list_all(State(pool): State<PgPool>) -> Json<Vec<User>> {

    // Declare the get user query
    let users = sqlx::query_as::<_, User>("SELECT id, username, email, password, title, created_at FROM users")
        .fetch_all(&pool).await.unwrap();

    // Path(name) extracts the parameter named 'name' from the URL
    Json(users)
}

// Handler to greet a user by name from the path
pub async fn get_by_id(Path(id): Path<i32>, State(pool): State<PgPool>) -> Json<User> {

    // Declare the get user query
    let user = sqlx::query_as::<_, User>("SELECT id, username, email, password, title, created_at FROM users WHERE id = $1")
        .bind(id).fetch_one(&pool).await.unwrap();

    Json(user)
}
