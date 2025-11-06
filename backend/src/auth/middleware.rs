use axum::{
    body::Body,
    http::{Request, StatusCode},
    response::Response,
    middleware::Next,
};
use headers::{authorization::Bearer, Authorization, HeaderMapExt};
use crate::auth::token_handler::verify_jwt;
use crate::models::auth::AuthUser;

pub async fn get_auth_user(mut req: Request<Body>, next: Next) -> Result<Response, StatusCode> {

    // Get client JWT token value
    let auth_user = match req.headers().typed_get::<Authorization<Bearer>>() {

        // If there is a token
        Some(auth_header) => {

            match verify_jwt(auth_header.token()) {

                // If token is valide, return auth user
                Ok(claims) => AuthUser {
                    user_id: claims.sub,
                    username: claims.username,
                    is_admin: claims.is_admin,
                    is_connected: true,
                },

                // If token is not valid return no user
                Err(_) => AuthUser {
                    user_id: -1,
                    username: "".to_string(),
                    is_admin: false,
                    is_connected: false,
                },
            }
        }

        // If there is no token, return AuthUser Not connected
        None => AuthUser {
            user_id: -1,
            username: "".to_string(),
            is_admin: false,
            is_connected: false,
        },
    };

    // Save the user in the extension
    req.extensions_mut().insert(auth_user);

    // Go to next request (handler)
    Ok(next.run(req).await)
}

