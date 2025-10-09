use serde::Serialize;
use chrono::NaiveDateTime;

#[derive(sqlx::FromRow, Serialize, Debug)]
pub struct User {
    pub id: i32,
    pub username: String,
    pub email: String,
    pub password: String,
    pub title: Option<String>,
    pub created_at: Option<NaiveDateTime>,
}
