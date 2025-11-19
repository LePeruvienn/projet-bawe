use axum::{extract::{Path, State, Form, Extension, Query}, Json, http::StatusCode};
use sqlx::PgPool;
use crate::models::post::{PostWithUserData, FormPost};
use crate::models::auth::AuthUser;
use crate::handlers::{DEFAULT_LIMIT, DEFAULT_OFFSET, PaginationQuery, auth_handlers::get_is_admin};


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

    // Create query
    let query = sqlx::query_as::<_, PostWithUserData>("
        SELECT
            p.id,
            p.content,
            p.created_at,
            p.likes_count,
            u.id AS user_id,
            u.username AS user_username,
            u.title AS user_title,
            u.created_at AS user_created_at,
            -- Check if a match was found in the LEFT JOIN
            CASE WHEN ul.user_id IS NOT NULL THEN TRUE ELSE FALSE END AS auth_is_liked
        FROM posts p
        JOIN users u ON p.user_id = u.id
        LEFT JOIN user_likes ul ON ul.post_id = p.id AND ul.user_id = $1
        ORDER BY p.created_at DESC, p.id DESC
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

    let is_admin = get_is_admin(&pool, &auth_user).await;

    // If user is not admin return 401
    if !is_admin {
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
pub async fn create_post(Extension(auth_user): Extension<AuthUser>, State(pool): State<PgPool>, Form(payload): Form<FormPost>) -> Result<Json<PostWithUserData>, StatusCode> {

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

    // Return 401 if user not connected
    if !auth_user.is_connected {
        return StatusCode::UNAUTHORIZED;
    }

    // Start transaction
    let mut tx = match pool.begin().await {
        Ok(t) => t,
        Err(_) => return StatusCode::INTERNAL_SERVER_ERROR,
    };

    // Insert like
    let insert_result = sqlx::query("INSERT INTO user_likes (user_id, post_id) VALUES ($1, $2)")
        .bind(auth_user.user_id)
        .bind(id)
        .execute(&mut *tx)
        .await;

    if insert_result.is_err() {
        // Maybe it can be CONFLICT be i'm not sure if it's 100% accurate
        return StatusCode::INTERNAL_SERVER_ERROR;
    }

    // Update like count
    let update_result = sqlx::query("UPDATE posts SET likes_count = likes_count + 1 WHERE id = $1")
        .bind(id)
        .execute(&mut *tx)
        .await;

    if update_result.is_err() {
        return StatusCode::INTERNAL_SERVER_ERROR;
    }

    // Commit -> Apply both queries
    if tx.commit().await.is_err() {
        return StatusCode::INTERNAL_SERVER_ERROR;
    }

    StatusCode::CREATED
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

    // Start transaction
    let mut tx = match pool.begin().await {
        Ok(t) => t,
        Err(_) => return StatusCode::INTERNAL_SERVER_ERROR,
    };

    // Delete like
    let delete_result = sqlx::query("DELETE FROM user_likes WHERE user_id = $1 AND post_id = $2")
        .bind(auth_user.user_id)
        .bind(id)
        .execute(&mut *tx)
        .await;

    if delete_result.is_err() {
        return StatusCode::INTERNAL_SERVER_ERROR;
    }

    // Update like count
    let update_result = sqlx::query("UPDATE posts SET likes_count = likes_count - 1 WHERE id = $1")
        .bind(id)
        .execute(&mut *tx)
        .await;

    if update_result.is_err() {
        return StatusCode::INTERNAL_SERVER_ERROR;
    }

    // Commit -> Apply both queries
    if tx.commit().await.is_err() {
        return StatusCode::INTERNAL_SERVER_ERROR;
    }

    StatusCode::OK
}
