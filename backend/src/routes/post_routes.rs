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

pub fn public_routes() -> Router<PgPool> {

    Router::new()
        .route("/{id}", get(get_by_id))
        .route("/delete/{id}", delete(delete_post))
}


fn protected_routes() -> Router<PgPool> {

    Router::new()
        .route("/", get(list_all))
        .route("/create", post(create_post))
        .route("/like/{id}", get(like_post))
        .route("/unlike/{id}", get(unlike_post))
        .route_layer(middleware::from_fn(get_auth_user))
}
pub fn routes() -> Router<PgPool> {

    // Merge both public & protected routes
    public_routes().merge(protected_routes())
}
