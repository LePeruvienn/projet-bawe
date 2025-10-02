use axum::{routing::get, Router, extract::Path, Json};
use std::net::SocketAddr;
use serde::Serialize;

pub mod handlers;
pub mod models;
pub mod routes;

use crate::routes::user_routes;

#[tokio::main] // Use the tokio runtime macro
async fn main() {
	// Build our application router
	let app = Router::new()
        .nest("/users/", user_routes::routes());

	// Define the address to run the server on
	let addr = SocketAddr::from(([127, 0, 0, 1], 3000));
	println!("🚀 Server listening on {}", addr);

	// Run the server
	let listener = tokio::net::TcpListener::bind(addr).await.unwrap();
	axum::serve(listener, app).await.unwrap();
}
