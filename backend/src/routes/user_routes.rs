use axum::{routing::get, Router};

use crate::handlers::user_handlers::{
    list_all,
    get_by_id
};


pub fn routes() -> Router {

    Router::new()
        .route("/", get(list_all))
        .route("/{id}", get(get_by_id))
}

