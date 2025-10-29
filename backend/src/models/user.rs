use serde::{Serialize, Deserialize};
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

#[derive(Deserialize)]
pub struct FormUser {
    pub username: String,
    pub email: String,
    pub password: String,
    pub title: Option<String>,
}
