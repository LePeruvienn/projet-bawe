use serde::Deserialize;

#[derive(Deserialize)]
pub struct FormUser {
    pub username: String,
    pub email: String,
    pub password: String,
    pub title: Option<String>,
}
