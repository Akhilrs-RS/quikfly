# Stage 1: Build the Dart backend native executable
FROM dart:stable AS build

WORKDIR /app

# Copy the shared package first to leverage Docker layer caching
COPY packages/quikfly_core ./packages/quikfly_core

# Copy backend pubspec and resolve dependencies
COPY backend/pubspec.yaml backend/pubspec.lock* ./backend/
WORKDIR /app/backend
RUN dart pub get

# Copy backend source code
COPY backend/lib ./lib
COPY backend/bin ./bin

# Compile self-contained native executable
RUN dart compile exe bin/server.dart -o /app/backend/server

# Stage 2: Runtime image using locally cached dart:stable
FROM dart:stable

WORKDIR /app

# Copy native binary from build stage
COPY --from=build /app/backend/server /app/server

# Expose default backend internal port
EXPOSE 8080

# Environment variables with container defaults
ENV PORT=8080 \
    MYSQL_HOST=mysql \
    MYSQL_PORT=3306 \
    MYSQL_DATABASE=quikfly_db \
    MYSQL_USER=quikfly \
    MYSQL_PASSWORD=quikfly_password

# Run the native compiled backend
CMD ["/app/server"]
