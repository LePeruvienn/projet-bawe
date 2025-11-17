use axum::{extract::{Path, State, Form, Extension, Query}, Json, http::StatusCode};
use sqlx::PgPool;
use crate::models::post::{PostWithUserData, FormPost};
use crate::models::auth::AuthUser;
use crate::handlers::{DEFAULT_LIMIT, DEFAULT_OFFSET, PaginationQuery};


/*
 * List all posts from the database
 * @auth {None} - no authorization needed
 */
pub async fn list(Extension(auth_user): Extension<AuthUser>, State(pool): State<PgPool>, Query(pagination): Query<PaginationQuery>) -> Result<Json<Vec<PostWithUserData>>, StatusCode> {

    // The goal is if the user is connected, return his likes, otherwise set all likes to false wit
    // user -1.
    let user_id = if auth_user.is_connected { auth_user.user_id } else { -1 };

    // Get values for pagination or else get default values
    let limit = pagination.limit.unwrap_or(DEFAULT_LIMIT); 
    let offset = pagination.offset.unwrap_or(DEFAULT_OFFSET);

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
            u.created_at as user_created_at,
            EXISTS (
                SELECT 1
                FROM user_likes ul 
                WHERE ul.user_id = $1 AND ul.post_id = p.id
            ) AS auth_is_liked
        FROM posts p
        JOIN users u ON p.user_id = u.id
        ORDER BY p.created_at DESC
        LIMIT $2
        OFFSET $3;
    ")
    .bind(user_id)
    .bind(limit)
    .bind(offset);

    let posts = query.fetch_all(&pool).await.map_err(|e| {
        eprintln!("Error fetching posts: {:?}", e);
        StatusCode::INTERNAL_SERVER_ERROR // Return 500 if SQL error
    })?;

    Ok(Json(posts))
}

/*
 * Get data from a specific post
 * @auth {None} - no authorization needed
 * @param {id} - post's id
 */
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
        StatusCode::INTERNAL_SERVER_ERROR // Return 500 if SQL error
    })?;

    Ok(Json(post))
}

/*
 * Delete a post
 * @auth {Admin} - only for admin users
 * @param {id} - post's id
 */
pub async fn delete_post(Path(id): Path<i32>, Extension(auth_user): Extension<AuthUser>, State(pool): State<PgPool>) -> StatusCode {

    // If user is not admin return 401
    if !auth_user.is_admin {
        return StatusCode::UNAUTHORIZED;
    }

    let query = sqlx::query("DELETE FROM posts WHERE id = $1;").bind(id);

    let result = query.execute(&pool).await;

    match result {

        Ok(res) if res.rows_affected() > 0 => StatusCode::NO_CONTENT, // Return 204 if success
        Ok(_) => StatusCode::NOT_FOUND, // Return 404 if no user found
        Err(_) => StatusCode::INTERNAL_SERVER_ERROR, // Return 500 if SQL error
    }
}

/*
 * Create a post and returns it with the user linked data
 * @auth {Conneceted} - only for conneceted users
 * @param {FormPost} - form input data
 */
pub async fn create_post(
    Extension(auth_user): Extension<AuthUser>,
    State(pool): State<PgPool>,
    Form(payload): Form<FormPost>,
) -> Result<Json<PostWithUserData>, StatusCode> {

    // If the user is not connected, return 401
    if !auth_user.is_connected {
        return Err(StatusCode::UNAUTHORIZED);
    }

    // Get user & form data
    let user_id = auth_user.user_id;
    let content = payload.content;

    let query = sqlx::query_as::<_, PostWithUserData>("
        WITH new_post AS (
            INSERT INTO posts (user_id, content) 
            VALUES ($1, $2) 
            RETURNING id, user_id, content, created_at, likes_count
        )
        SELECT 
            np.id, 
            np.content, 
            np.created_at, 
            np.likes_count, 
            u.id as user_id, 
            u.username as user_username, 
            u.title as user_title, 
            u.created_at as user_created_at,
            EXISTS (
                SELECT 1 
                FROM user_likes ul 
                WHERE ul.user_id = $3 AND ul.post_id = np.id
            ) AS auth_is_liked 
        FROM new_post np 
        JOIN users u ON np.user_id = u.id;
    ")
    .bind(user_id)
    .bind(content)
    .bind(user_id);

    let post = query.fetch_one(&pool).await
        .map_err(|_| StatusCode::INTERNAL_SERVER_ERROR)?;

    // Return the created post
    Ok(Json(post))
}

/*
 * Like a post
 * @auth {Conneceted} - only for conneceted users
 * @param {id} - post's id you want to like
 */
pub async fn like_post(Path(id): Path<i32>, Extension(auth_user): Extension<AuthUser>, State(pool): State<PgPool>) -> StatusCode {

    // If user is not connected return 401
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
        return StatusCode::CONFLICT; // Return 409 if user already liked the post
    }

    // Attempt to insert a like
    let result = sqlx::query("INSERT INTO user_likes (user_id, post_id) VALUES ($1, $2);")
        .bind(auth_user.user_id)
        .bind(id)
        .execute(&pool)
        .await;

    match result {
        Ok(_) => StatusCode::CREATED, // Return 201 if success
        Err(_) => StatusCode::INTERNAL_SERVER_ERROR, // Return 500 if SQL error
    }
}

/*
 * Unlike a post
 * @auth {Conneceted} - only for conneceted users
 * @param {id} - post's id you want to unlike
 */
pub async fn unlike_post(Path(id): Path<i32>, Extension(auth_user): Extension<AuthUser>, State(pool): State<PgPool>) -> StatusCode {

    // Return 401 if user not connected
    if !auth_user.is_connected {
        return StatusCode::UNAUTHORIZED;
    }

    // Check if post exist
    let post_exists = sqlx::query("SELECT 1 FROM posts WHERE id = $1")
        .bind(id)
        .fetch_optional(&pool)
        .await;

    // If post dont exist return 404
    if post_exists.is_err() || post_exists.unwrap().is_none() {
        return StatusCode::NOT_FOUND;
    }

    // Check if user have liked the post
    let like_exists = sqlx::query("SELECT 1 FROM user_likes WHERE user_id = $1 AND post_id = $2")
        .bind(auth_user.user_id)
        .bind(id)
        .fetch_optional(&pool)
        .await;

    // If user hasnt like the post we return 404
    if like_exists.is_err() || like_exists.unwrap().is_none() {
        return StatusCode::NOT_FOUND;
    }

    // Unlike the post
    let result = sqlx::query("DELETE FROM user_likes WHERE user_id = $1 AND post_id = $2")
        .bind(auth_user.user_id)
        .bind(id)
        .execute(&pool)
        .await;

    match result {
        Ok(_) => StatusCode::OK, // Return 200 if success
        Err(_) => StatusCode::INTERNAL_SERVER_ERROR, // Return 500 if SQL error
    }
}
