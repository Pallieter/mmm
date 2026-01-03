# MMM Task Manager

This is a PoC for a Task Management System with Mind Map, Tree, and Table views.

## Project Structure

- `frontend/`: Flutter Web application.
- `backend/`: Dart Shelf server (REST API).
- `shared/`: Shared Dart models.
- `deploy.sh`: Deployment script.

## Setup Instructions

### Prerequisites
- Dart SDK
- Flutter SDK
- MySQL Database

### Configuration

1. **Google Sign-In**:
   - Create a Google Cloud Project.
   - Create an OAuth 2.0 Client ID for Web.
   - Update `frontend/lib/auth_provider.dart` with your `clientId`.
   - Update `frontend/web/index.html` (add the meta tag if required by the latest library, though v7 is pure Dart usually).

2. **Database**:
   - Create a MySQL database (e.g., `mmm_db`).
   - The application will automatically create tables (`users`, `task_nodes`) on startup if connected.

### Running Locally (Development)

1. **Start Backend**:
   ```bash
   cd backend
   export DB_PASS=your_db_pass
   dart run bin/server.dart
   ```

2. **Start Frontend**:
   ```bash
   cd frontend
   flutter run -d chrome
   ```

### Deployment

1. Run the deployment script:
   ```bash
   ./deploy.sh
   ```
   This will create a `dist/` directory containing the compiled backend binary and the static frontend files.

2. Upload `dist/` to your server.

3. Run the server:
   ```bash
   cd dist
   export DB_PASS=your_mysql_password
   export PORT=8080
   ./run.sh
   ```
   The application will be available at `http://your-server:8080`.

## License
GPL v3
