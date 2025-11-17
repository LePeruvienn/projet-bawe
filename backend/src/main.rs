use axum::Router;
use std::net::SocketAddr;
use dotenvy::dotenv;
use sqlx::postgres::PgPoolOptions;
use std::env;
use std::time::Duration;
use tokio::time::sleep;
use tower_http::cors::{CorsLayer, Any};

pub mod handlers;
pub mod models;
pub mod routes;
pub mod auth;

use crate::routes::user_routes;
use crate::routes::post_routes;
use crate::routes:: auth_routes;

/*
 * Try to connect to the database with multiplie tries
 * @param {String} database_url - the database url we want to connect
 * @param {uint8}  retries - how many times we want to try connect before giving up
 * @param {uint64} delay - how many time to wait between each try
 */
async fn wait_for_db(database_url: &str, retries: u8, delay_secs: u64) -> sqlx::Pool<sqlx::Postgres> {

    let mut attempts = retries;

    loop {
        match PgPoolOptions::new()
            .max_connections(5)
            .connect(database_url)
            .await
        {
            Ok(pool) => {
                println!("Connected to database!");
                return pool;
            }
            Err(e) => {
                if attempts == 0 {
                    panic!("Error: Could not connect to database: {:?}", e);
                }
                println!("Waiting for database... ({})", e);
                attempts -= 1;
                sleep(Duration::from_secs(delay_secs)).await; // <- fonctionne maintenant
            }
        }
    }
}

/********************
 *      MAIN        *
 ********************/

#[tokio::main]
async fn main() {

    // Ensure env variable are accessible
    dotenv().ok();

    // Configure CORS layer
    let cors = CorsLayer::new()
        .allow_origin(Any)
        .allow_methods(Any)
        .allow_headers(Any);

    // Get database_url from env variable
    let database_url = env::var("DATABASE_URL").expect("DATABASE_URL must be set");

    // Try getting DB connnection
    let pool = wait_for_db(&database_url, 10, 2).await;

    // Create http router with all paths and routes
    let app = Router::new()
        .nest("/users", user_routes::routes())
        .nest("/posts", post_routes::routes())
        .nest("/auth", auth_routes::routes())
        .with_state(pool.clone())
        .layer(cors);

    // Create new adress where the API is gonna listen
    let addr = SocketAddr::from(([0, 0, 0, 0], 8080));

    println!("🚀 Server listening on {}", addr);

    // Create a new listener for this adress
    let listener = tokio::net::TcpListener::bind(addr).await.unwrap();

    // Run the API
    axum::serve(listener, app).await.unwrap();
}
