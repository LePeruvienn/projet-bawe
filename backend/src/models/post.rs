use serde::{Serialize, Deserialize};
use chrono::NaiveDateTime;

#[derive(sqlx::FromRow, Serialize, Debug)]
pub struct Post {
    pub id: i32,
    pub user_id: i32,
    pub content: String,
    pub created_at: Option<NaiveDateTime>,
    pub likes_count: i32,
}


#[derive(sqlx::FromRow, Serialize, Debug)]
pub struct PostWithUserData {

    pub id: i32,
    pub content: String,
    pub created_at: Option<NaiveDateTime>,
    pub likes_count: i32,
    pub user_id: i32,
    pub user_username: String,
    pub user_title: Option<String>,
    pub user_created_at: Option<NaiveDateTime>,
}

#[derive(Deserialize)]
pub struct FormPost {
    pub content: String,
}
