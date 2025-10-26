use jsonwebtoken::{encode, decode, Header, Validation, EncodingKey, DecodingKey};
use serde::{Serialize, Deserialize};
use std::env;

// TODO: IMPROVE THIS : MAKE JWT TOKEN CREATION GOOD

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Claims {
    pub sub: String,   // user id
    pub exp: usize,    // expiration timestamp
}

pub fn create_jwt(user_id: &str) -> String {
    
    let secret = env::var("JWT_SECRET").expect("JWT_SECRET must be set");

    let expiration = chrono::Utc::now()
        .checked_add_signed(chrono::Duration::hours(24))
        .unwrap()
        .timestamp() as usize;

    let claims = Claims { sub: user_id.to_string(), exp: expiration };
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

