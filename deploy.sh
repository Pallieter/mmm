#!/bin/bash
set -e

echo "deploy.sh: Starting deployment process..."

# 1. Build Backend
echo "Building Backend..."
cd backend
dart pub get
dart compile exe bin/server.dart -o server
cd ..

# 2. Build Frontend
echo "Building Frontend..."
cd frontend
flutter pub get
flutter build web --release
cd ..

# 3. Prepare Deployment Directory
echo "Preparing deployment artifacts in ./dist ..."
rm -rf dist
mkdir -p dist/public
cp backend/server dist/
cp -r frontend/build/web/* dist/public/

# 4. Create a helper runner script
cat <<EOF > dist/run.sh
#!/bin/bash

# Check required environment variables
missing_vars=0

if [ -z "\$DB_USER" ]; then
  echo "Error: DB_USER environment variable is not set."
  missing_vars=1
fi

if [ -z "\$DB_PASS" ]; then
  echo "Error: DB_PASS environment variable is not set."
  missing_vars=1
fi

if [ -z "\$DB_HOST" ]; then
  echo "Error: DB_HOST environment variable is not set. (Defaulting to localhost if desired, but explicit is better)"
  # Optionally set default here if you want to allow it, but failing fast is requested.
  # We will fail fast for Host as well to be safe, or you can uncomment below.
  # export DB_HOST=localhost
  echo "Error: DB_HOST environment variable is not set."
  missing_vars=1
fi

if [ -z "\$DB_NAME" ]; then
    echo "Error: DB_NAME environment variable is not set."
    missing_vars=1
fi

if [ \$missing_vars -eq 1 ]; then
  echo "Exiting due to missing environment variables."
  exit 1
fi

# Optional defaults for non-sensitive data
export DB_PORT=\${DB_PORT:-3306}
export PORT=\${PORT:-8080}

echo "Starting server on port \$PORT..."
./server
EOF
chmod +x dist/run.sh

echo "Deployment build complete. Artifacts are in ./dist"
echo "To run: cd dist && export DB_HOST=... DB_USER=... DB_PASS=... DB_NAME=... && ./run.sh"
