use serde::{Deserialize, Serialize};

#[derive(Clone)]
pub struct AuthUser {
    pub user_id: i32,
    pub username: String,
    pub is_connected: bool,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Claims {
    pub username: String,
    pub sub: i32,   // user id
    pub exp: usize, // expiration timestamp
}


#[derive(Deserialize)]
pub struct LoginRequest {
    pub username: String,
    pub password: String,
}

#[derive(Serialize)]
pub struct TokenResponse {
    pub token: String,
}
