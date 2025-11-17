use serde::{Deserialize, Serialize};

// This is data we get from middleware of the user try to do a request
#[derive(Clone)]
pub struct AuthUser {
    pub user_id: i32,
    pub username: String,
    pub is_admin: bool,
    pub is_connected: bool
}

// This is the claims structure used to store data in the JWT key
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Claims {
    pub username: String,
    pub is_admin: bool,
    pub sub: i32,   // user id
    pub exp: usize  // expiration timestamp
}

// JSON client must send to attempt to an login request
#[derive(Deserialize)]
pub struct LoginRequest {
    pub username: String,
    pub password: String,
}

// Response send to client when user sucessfully connected
#[derive(Serialize)]
pub struct TokenResponse {
    pub token: String,
}
