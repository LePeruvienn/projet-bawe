use axum::{extract::{Path, State/*, Form*/}, Json, http::StatusCode};
use sqlx::PgPool;
use crate::models::post::Post;
// use crate::forms::post_forms::Formpost;

// TODO: >>> ALL 

// Handler to greet a post by name from the path
pub async fn list_all(State(pool): State<PgPool>) -> Result<Json<Vec<Post>>, StatusCode> {

    let query = sqlx::query_as::<_, Post>("SELECT id, user_id, content, created_at, likes_count FROM posts");

    let posts = query.fetch_all(&pool).await
        .map_err(|_| StatusCode::INTERNAL_SERVER_ERROR)?; // retourne 500 si erreur SQL
    //
    Ok(Json(posts))
}

// Handler to greet a post by name from the path
pub async fn get_by_id(Path(id): Path<i32>, State(pool): State<PgPool>) -> Result<Json<Post>, StatusCode> {

    let query = sqlx::query_as::<_, Post>("SELECT id, user_id, content, created_at, likes_count FROM posts WHERE id = $1").bind(id);

    let post = query.fetch_one(&pool).await
        .map_err(|_| StatusCode::INTERNAL_SERVER_ERROR)?; // retourne 500 si erreur SQL

    Ok(Json(post))
}

/* TODO:
* 
pub async fn create_post(State(pool): State<PgPool>, Form(payload): Form<Formpost>) -> StatusCode {

    let query = sqlx::query("INSERT INTO posts (postname, email, password, title) VALUES ($1, $2, $3, $4);")
        .bind(&payload.postname)
        .bind(&payload.email)
        .bind(&payload.password)
        .bind(&payload.title);

    let result = query.execute(&pool).await;

    match result {

        Ok(_) => StatusCode::CREATED, // 201
        Err(_) => StatusCode::INTERNAL_SERVER_ERROR // erreur SQL
    }
}
*/

pub async fn delete_post(Path(id): Path<i32>, State(pool): State<PgPool>) -> StatusCode {

    let query = sqlx::query("DELETE FROM posts WHERE id = $1;").bind(id);

    let result = query.execute(&pool).await;

    match result {

        Ok(res) if res.rows_affected() > 0 => StatusCode::NO_CONTENT, // 204
        Ok(_) => StatusCode::NOT_FOUND, // aucun utilisateur supprimé
        Err(_) => StatusCode::INTERNAL_SERVER_ERROR, // erreur SQL
    }
}
