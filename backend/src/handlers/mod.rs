use serde::Deserialize;

// Expose rust files
pub mod user_handlers;
pub mod post_handlers;
pub mod auth_handlers;

// It's defined here cause it's the same one of user and post handlers

// PaginationQuery constants
pub const DEFAULT_LIMIT: i64  = 10;
pub const DEFAULT_OFFSET: i64 = 0;

// This is for the list_posts methods, here is all the getter attribute you can give
#[derive(Deserialize)]
pub struct PaginationQuery {
    pub offset: Option<i64>, // The number of posts to skip
    pub limit: Option<i64>,   // The maximum number of posts to return
    // pub since_created_at: Option<String>
}
