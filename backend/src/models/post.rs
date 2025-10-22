use serde::Serialize;
use chrono::NaiveDateTime;

#[derive(sqlx::FromRow, Serialize, Debug)]
pub struct Post {
    pub id: i32,
    pub user_id: i32,
    pub content: String,
    pub created_at: Option<NaiveDateTime>,
    pub likes_count: i32,
}
