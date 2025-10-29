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

/// Essaie de se connecter à la DB avec des retries
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

#[tokio::main]
async fn main() {
    dotenv().ok();

    let cors = CorsLayer::new()
        .allow_origin(Any)
        .allow_methods(Any)
        .allow_headers(Any);

    let database_url = env::var("DATABASE_URL").expect("DATABASE_URL must be set");

    let pool = wait_for_db(&database_url, 10, 2).await;

    let app = Router::new()
        .nest("/users", user_routes::routes())
        .nest("/posts", post_routes::routes())
        .nest("/auth", auth_routes::routes())
        .with_state(pool.clone())
        .layer(cors);

    let addr = SocketAddr::from(([0, 0, 0, 0], 8080));
    println!("🚀 Server listening on {}", addr);

    let listener = tokio::net::TcpListener::bind(addr).await.unwrap();
    axum::serve(listener, app).await.unwrap();
}
