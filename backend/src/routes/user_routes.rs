use axum::{routing::{get, post}, Router};
use sqlx::PgPool;
use crate::handlers::user_handlers::{
    list_all,
    get_by_id,
    create_user
};

pub fn routes() -> Router<PgPool> {

    Router::new()
        .route("/", get(list_all))
        .route("/{id}", get(get_by_id))
        .route("/create", post(create_user))
}

