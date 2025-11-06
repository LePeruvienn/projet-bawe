use jsonwebtoken::{encode, decode, Header, Validation, EncodingKey, DecodingKey};
use std::env;
use crate::models::auth::Claims;

pub fn create_jwt(user_id: i32, username: String, is_admin: bool) -> String {

    let secret = env::var("JWT_SECRET").expect("JWT_SECRET must be set");

    let expiration = chrono::Utc::now()
        .checked_add_signed(chrono::Duration::hours(24))
        .unwrap()
        .timestamp() as usize;

    let claims = Claims{
        username: username,
        is_admin: is_admin,
        sub: user_id,
        exp: expiration
    };

    encode(&Header::default(), &claims, &EncodingKey::from_secret(secret.as_ref())).unwrap()
}

pub fn verify_jwt(token: &str) -> Result<Claims, jsonwebtoken::errors::Error> {

    let secret = env::var("JWT_SECRET").expect("JWT_SECRET must be set");

    let data = decode::<Claims>(
        token,
        &DecodingKey::from_secret(secret.as_ref()),
        &Validation::default(),
    )?;

    Ok(data.claims)
}
