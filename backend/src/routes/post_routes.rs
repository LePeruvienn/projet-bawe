use axum::{routing::{get, post, delete}, Router, middleware};
use sqlx::PgPool;

use crate::auth::middleware::get_auth_user;

use crate::handlers::post_handlers::{
    list_all,
    get_by_id,
    create_post,
    delete_post,
    like_post,
    unlike_post
};

/*
 * All routes that DOESNT need you to be auth
 */
pub fn public_routes() -> Router<PgPool> {

    Router::new()
        .route("/{id}", get(get_by_id)) // Unused routes, still here but must update ()
}


/*
 * All routes that NEED you to be auth
 * - Each request is gonna get trought a middleware to ensure the user authentification
 */
fn protected_routes() -> Router<PgPool> {

    Router::new()
        .route("/", get(list_all))
        .route("/create", post(create_post))
        .route("/delete/{id}", delete(delete_post))
        .route("/like/{id}", get(like_post))
        .route("/unlike/{id}", get(unlike_post))
        .route_layer(middleware::from_fn(get_auth_user))
}

/*
 * Public function to expose routes for main.rs
 */
pub fn routes() -> Router<PgPool> {

    // Merge both public & protected routes
    public_routes().merge(protected_routes())
}
