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

/*
 * All routes that DOESNT need you to be auth
 */
fn public_routes() -> Router<PgPool> {

    Router::new()
        .route("/create", post(create_user))
}

/*
 * All routes that NEED you to be auth
 * - Each request is gonna get trought a middleware to ensure the user authentification
 */
fn protected_routes() -> Router<PgPool> {

    Router::new()
        .route("/", get(list_all))
        .route("/{id}", get(get_by_id))
        .route("/me", get(get_connected))
        .route("/delete/{id}", delete(delete_user))
        .route("/update/{id}", put(update_user))
        .route_layer(middleware::from_fn(get_auth_user))
}

/*
 * Public function to expose routes for main.rs
 */
pub fn routes() -> Router<PgPool> {

    // Merge boths routes
    public_routes().merge(protected_routes())
}

