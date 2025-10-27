use axum::{Router, routing::post};
use sqlx::PgPool;

use crate::handlers::auth_handlers::login;

pub fn routes() -> Router<PgPool> {

    Router::new().route("/login", post(login))
}
