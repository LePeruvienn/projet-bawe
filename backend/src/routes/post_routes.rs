use axum::{routing::{get, post, delete, put}, Router};
use sqlx::PgPool;
use crate::handlers::user_handlers::{
    list_all,
    get_by_id,
    create_user,
    delete_user,
    update_user
};

// TODO: >>> RE CODE ALL METHODS

pub fn routes() -> Router<PgPool> {

    Router::new()
        .route("/", get(list_all))
        .route("/{id}", get(get_by_id))
        .route("/create", post(create_user))
        .route("/delete/{id}", delete(delete_user))
}

