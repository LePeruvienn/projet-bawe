use serde::{Serialize, Deserialize};
use chrono::NaiveDateTime;

// Struct representing the SQL User table
#[derive(sqlx::FromRow, Serialize, Debug)]
pub struct User {
    pub id: i32,
    pub username: String,
    pub email: String,
    pub password: String,
    pub title: Option<String>,
    pub created_at: Option<NaiveDateTime>,
    pub is_admin: bool
}

// JSON client must send to create an user
#[derive(Deserialize)]
pub struct FormUser {
    pub username: String,
    pub email: String,
    pub password: String,
    pub title: Option<String>,
    pub is_admin: bool
}
