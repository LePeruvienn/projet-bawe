# Stage 1: Build
FROM rustlang/rust:nightly AS builder
WORKDIR /app

# Copier les fichiers Cargo et le code source
COPY Cargo.toml Cargo.lock ./
COPY src ./src

# Compiler en release
RUN cargo build --release

# Stage 2: Runtime léger
FROM debian:bookworm-slim
WORKDIR /app

# Copier l'exécutable depuis le stage build
COPY --from=builder /app/target/release/backend /app/backend

# Exposer le port de l'API
EXPOSE 8080

# Commande pour lancer le serveur
CMD ["./backend"]
