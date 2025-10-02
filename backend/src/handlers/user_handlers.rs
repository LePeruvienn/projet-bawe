use axum::{extract::Path, Json};

use crate::models::user::User;

// Handler to greet a user by name from the path
pub async fn list_all() -> Json<Vec<User>> {

    let datas = vec![
        User{ id: 0, name: "Doryan".to_string() },
        User{ id: 1, name: "Matteo".to_string() },
        User{ id: 2, name: "FEUR".to_string() },
        User{ id: 3, name: "Damien".to_string() },
        User{ id: 4, name: "MOI".to_string() },
        User{ id: 5, name: "Dimitri".to_string() }
    ];

    // Path(name) extracts the parameter named 'name' from the URL
    Json(datas)
}

// Handler to greet a user by name from the path
pub async fn get_by_id(Path(id): Path<i32>) -> Json<User> {

    let datas = vec![
        User{ id: 0, name: "Doryan".to_string() },
        User{ id: 1, name: "Matteo".to_string() },
        User{ id: 2, name: "FEUR".to_string() },
        User{ id: 3, name: "Damien".to_string() },
        User{ id: 4, name: "MOI".to_string() },
        User{ id: 5, name: "Dimitri".to_string() }
    ];

    let index = id as usize;

    Json(datas[index].clone())
}
