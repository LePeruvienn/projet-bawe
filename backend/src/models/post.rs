use serde::{Serialize, Deserialize};
use chrono::NaiveDateTime;

// Basic Post Strct reprenseting the SQL table datas
#[derive(sqlx::FromRow, Serialize, Debug)]
pub struct Post {
    pub id: i32,
    pub user_id: i32,
    pub content: String,
    pub created_at: Option<NaiveDateTime>,
    pub likes_count: i32
}

// Struct used to send the post data with the user data
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
    pub auth_is_liked: bool
}

// JSON client must send to create a post (only content is necessary, auth is handled by
// middleware)
#[derive(Deserialize)]
pub struct FormPost {
    pub content: String,
}
