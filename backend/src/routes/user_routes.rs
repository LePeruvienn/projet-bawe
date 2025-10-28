use axum::{routing::{get, post, delete, put}, Router, middleware};
use sqlx::PgPool;

use crate::auth::middleware::get_auth_user;

use crate::handlers::user_handlers::{
    list_all,
    get_by_id,
    create_user,
    delete_user,
    update_user,
    get_connected
};

// All routes DOESNT NEED you to be auth
fn public_routes() -> Router<PgPool> {

    Router::new()
        .route("/", get(list_all))
        .route("/{id}", get(get_by_id))
        .route("/create", post(create_user))
        .route("/delete/{id}", delete(delete_user))
        .route("/update/{id}", put(update_user))
}

// All routes that NEED you to be auth
fn protected_routes() -> Router<PgPool> {

    Router::new()
        .route("/me", get(get_connected))
        .route_layer(middleware::from_fn(get_auth_user))
}

pub fn routes() -> Router<PgPool> {

    Router::new()
        .nest("/public", public_routes())
        .nest("/protected", protected_routes())
}

