use axum::Router;
use std::net::SocketAddr;
use dotenvy::dotenv;
use sqlx::postgres::PgPoolOptions;
use std::env;
use tower_http::cors::{CorsLayer, Any};

pub mod handlers;
pub mod models;
pub mod routes;
pub mod forms;

use crate::routes::user_routes;

#[tokio::main] // Use the tokio runtime macro
async fn main() {

    dotenv().ok();

    // Allow cors
    let cors = CorsLayer::new()
        .allow_origin(Any)
        .allow_methods(Any)
        .allow_headers(Any);

    // Get databas url
    let database_url = env::var("DATABASE_URL").expect("DATABASE_URL must be set");

    // Create a connection pool
    let pool = PgPoolOptions::new()
        .max_connections(5)
        .connect(&database_url)
        .await.unwrap();

    // Build our application router
    let app = Router::new()
        .nest("/users/", user_routes::routes())
        .with_state(pool.clone())
        .layer(cors);
    //
    // Define the address to run the server on
    let addr = SocketAddr::from(([0, 0, 0, 0], 8080));
    println!("🚀 Server listening on {}", addr);

    // Run the server
    let listener = tokio::net::TcpListener::bind(addr).await.unwrap();
    axum::serve(listener, app).await.unwrap();
}
