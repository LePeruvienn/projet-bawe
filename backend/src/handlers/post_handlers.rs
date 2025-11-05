use axum::{extract::{Path, State, Form, Extension}, Json, http::StatusCode};
use sqlx::PgPool;
use crate::models::post::{PostWithUserData, FormPost};
use crate::models::auth::AuthUser;

// TODO: >>> ALL 

pub async fn list_all(State(pool): State<PgPool>) -> Result<Json<Vec<PostWithUserData>>, StatusCode> {

    print!("post_handlers : list_all ...");

    let query = sqlx::query_as::<_, PostWithUserData>("
        SELECT 
            p.id,
            p.content,
            p.created_at,
            p.likes_count,
            u.id as user_id,
            u.username as user_username,
            u.title as user_title,
            u.created_at as user_created_at
        FROM posts p
        JOIN users u ON p.user_id = u.id;
        ");

    let posts = query.fetch_all(&pool).await.map_err(|e| {
        eprintln!("Error fetching posts: {:?}", e);
        StatusCode::INTERNAL_SERVER_ERROR
    })?;

    Ok(Json(posts))
}

// Handler to greet a post by name from the path
pub async fn get_by_id(Path(id): Path<i32>, State(pool): State<PgPool>) -> Result<Json<PostWithUserData>, StatusCode> {

    let query = sqlx::query_as::<_, PostWithUserData>("
        SELECT 
            p.id,
            p.content,
            p.created_at,
            p.likes_count,
            u.id as user_id,
            u.username as user_username,
            u.title as user_title,
            u.created_at as user_created_at
        FROM posts p
        JOIN users u ON p.user_id = u.id
        WHERE p.id = $1;
        ").bind(id);

    let post = query.fetch_one(&pool).await.map_err(|e| {
        eprintln!("Error fetching posts: {:?}", e);
        StatusCode::INTERNAL_SERVER_ERROR
    })?;

    Ok(Json(post))
}

pub async fn delete_post(Path(id): Path<i32>, State(pool): State<PgPool>) -> StatusCode {

    let query = sqlx::query("DELETE FROM posts WHERE id = $1;").bind(id);

    let result = query.execute(&pool).await;

    match result {

        Ok(res) if res.rows_affected() > 0 => StatusCode::NO_CONTENT, // 204
        Ok(_) => StatusCode::NOT_FOUND, // aucun utilisateur supprimé
        Err(_) => StatusCode::INTERNAL_SERVER_ERROR, // erreur SQL
    }
}

pub async fn create_post(Extension(auth_user): Extension<AuthUser>, State(pool): State<PgPool>, Form(payload): Form<FormPost>) -> StatusCode {

    println!("CREATE_POST: Trying to get connected user ...");

    // If user is not connected we return UNAUTHORIZED
    if !auth_user.is_connected {
        return StatusCode::UNAUTHORIZED;
    }

    // Get query data
    let username = auth_user.username;
    let user_id = auth_user.user_id;
    let content = payload.content;

    println!("CREATE POST: User is connected with @{username}");

    let query = sqlx::query("INSERT INTO posts (user_id, content) VALUES ($1, $2);")
        .bind(user_id)
        .bind(content);

    let result = query.execute(&pool).await;

    println!("CREATE POST: Executed SQL query");

    match result {

        Ok(_) => StatusCode::CREATED, // 201
        Err(_) => StatusCode::INTERNAL_SERVER_ERROR // erreur SQL
    }
}

pub async fn like_post(Path(id): Path<i32>, Extension(auth_user): Extension<AuthUser>, State(pool): State<PgPool>) -> StatusCode {

    // Ensure the user is connected
    if !auth_user.is_connected {
        return StatusCode::UNAUTHORIZED;
    }

    // Check if the post exists
    let post_exists = sqlx::query("SELECT 1 FROM posts WHERE id = $1")
        .bind(id)
        .fetch_optional(&pool)
        .await;

    // If post dont exist return 404 not found
    if post_exists.is_err() || post_exists.unwrap().is_none() {
        return StatusCode::NOT_FOUND;
    }

    // Check if the user already likes the post
    let like_exists = sqlx::query("SELECT 1 FROM user_likes WHERE user_id = $1 AND post_id = $2")
        .bind(auth_user.user_id)
        .bind(id)
        .fetch_optional(&pool)
        .await;

    if like_exists.is_ok() && like_exists.unwrap().is_some() {
        return StatusCode::CONFLICT; // 409: User has already liked this post
    }

    // Attempt to insert a like
    let result = sqlx::query("INSERT INTO user_likes (user_id, post_id) VALUES ($1, $2);")
        .bind(auth_user.user_id)
        .bind(id)
        .execute(&pool)
        .await;

    match result {
        Ok(_) => StatusCode::CREATED, // 201: Like was added
        Err(_) => StatusCode::INTERNAL_SERVER_ERROR, // SQL error
    }
}

pub async fn unlike_post(Path(id): Path<i32>, Extension(auth_user): Extension<AuthUser>, State(pool): State<PgPool>) -> StatusCode {

    // Ensure user in connected
    if !auth_user.is_connected {
        return StatusCode::UNAUTHORIZED;
    }

    // Check if post exist
    let post_exists = sqlx::query("SELECT 1 FROM posts WHERE id = $1")
        .bind(id)
        .fetch_optional(&pool)
        .await;

    // If post dont exist return
    if post_exists.is_err() || post_exists.unwrap().is_none() {
        return StatusCode::NOT_FOUND; // 404
    }

    // Check if user have liked the post
    let like_exists = sqlx::query("SELECT 1 FROM user_likes WHERE user_id = $1 AND post_id = $2")
        .bind(auth_user.user_id)
        .bind(id)
        .fetch_optional(&pool)
        .await;

    // If not return NOT FOUND
    if like_exists.is_err() || like_exists.unwrap().is_none() {
        return StatusCode::NOT_FOUND; // 404
    }

    // Unlike the post
    let result = sqlx::query("DELETE FROM user_likes WHERE user_id = $1 AND post_id = $2")
        .bind(auth_user.user_id)
        .bind(id)
        .execute(&pool)
        .await;

    match result {
        Ok(_) => StatusCode::OK, // 200 
        Err(_) => StatusCode::INTERNAL_SERVER_ERROR, // 500
    }
}
