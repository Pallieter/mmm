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
export DB_HOST=\${DB_HOST:-localhost}
export DB_PORT=\${DB_PORT:-3306}
export DB_USER=\${DB_USER:-root}
export DB_PASS=\${DB_PASS:-password}
export DB_NAME=\${DB_NAME:-mmm_db}
export PORT=\${PORT:-8080}

# Serve static files logic would usually be in the dart server,
# For PoC, we will assume the User runs a separate web server (nginx) for frontend
# OR we update backend to serve static files.
# Let's update backend to serve static files for simplicity.

./server
EOF
chmod +x dist/run.sh

echo "Deployment build complete. Artifacts are in ./dist"
echo "To run: cd dist && ./run.sh"
