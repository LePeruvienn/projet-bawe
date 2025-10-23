use axum::{routing::{get, /*post,*/ delete}, Router};
use sqlx::PgPool;
use crate::handlers::post_handlers::{
    list_all,
    get_by_id,
    /*create_post,*/
    delete_post
};

pub fn routes() -> Router<PgPool> {

    Router::new()
        .route("/", get(list_all))
        .route("/{id}", get(get_by_id))
        /*.route("/create", post(create_post))*/
        .route("/delete/{id}", delete(delete_post))
}

