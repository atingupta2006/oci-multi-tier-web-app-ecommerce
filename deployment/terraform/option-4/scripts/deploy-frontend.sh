#!/bin/bash
# BharatMart Frontend Deployment Script
# This script is executed on the frontend VM via Terraform provisioner

set -e
set -x

# Configuration Variables (can be overridden by environment variables)
APP_DIR="${FRONTEND_APP_DIR:-/opt/bharatmart-frontend}"
REPO_URL="${REPO_URL:-https://github.com/atingupta2006/oci-multi-tier-web-app-ecommerce.git}"
REPO_BRANCH="${REPO_BRANCH:-main}"
NGINX_ROOT="/usr/share/nginx/html"
NGINX_CONFIG="/etc/nginx/conf.d/bharatmart.conf"

# Log file for deployment
LOG_FILE="/var/log/bharatmart-frontend-deployment.log"

# Logging function
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

log "=========================================="
log "Starting BharatMart Frontend Deployment"
log "=========================================="

# Step 1: System Update
log "Step 1: Updating system packages..."
sudo yum update -y >> "$LOG_FILE" 2>&1

# Step 2: Install Node.js 20
log "Step 2: Installing Node.js..."
if ! command -v node &> /dev/null; then
    curl -fsSL https://rpm.nodesource.com/setup_20.x | sudo bash - >> "$LOG_FILE" 2>&1
    sudo yum install -y nodejs >> "$LOG_FILE" 2>&1
    log "Node.js $(node --version) installed"
else
    log "Node.js already installed: $(node --version)"
fi

# Step 3: Install Git
log "Step 3: Installing Git..."
if ! command -v git &> /dev/null; then
    sudo yum install -y git >> "$LOG_FILE" 2>&1
    log "Git installed: $(git --version)"
else
    log "Git already installed: $(git --version)"
fi

# Step 4: Install Nginx
log "Step 4: Installing Nginx..."
if ! command -v nginx &> /dev/null; then
    sudo yum install -y nginx >> "$LOG_FILE" 2>&1
    log "Nginx installed: $(nginx -v 2>&1)"
else
    log "Nginx already installed: $(nginx -v 2>&1)"
fi

# Step 5: Create application directory
log "Step 5: Creating application directory at $APP_DIR..."
sudo mkdir -p "$APP_DIR"
sudo chown -R opc:opc "$APP_DIR"
cd "$APP_DIR"

# Step 6: Clone repository (if not already cloned)
log "Step 6: Cloning repository..."
if [ ! -d ".git" ]; then
    git clone -b "$REPO_BRANCH" "$REPO_URL" . >> "$LOG_FILE" 2>&1
    log "Repository cloned successfully"
else
    log "Repository already exists, pulling latest changes..."
    git fetch origin >> "$LOG_FILE" 2>&1
    git checkout "$REPO_BRANCH" >> "$LOG_FILE" 2>&1
    git pull origin "$REPO_BRANCH" >> "$LOG_FILE" 2>&1
    log "Repository updated"
fi

# Step 7: Install npm dependencies
log "Step 7: Installing npm dependencies..."
npm install >> "$LOG_FILE" 2>&1
log "Dependencies installed successfully"

# Step 8: Create .env file from template or uploaded file
log "Step 8: Setting up environment file..."
if [ -f "/tmp/frontend.env" ]; then
    # Use uploaded .env file if available
    cp /tmp/frontend.env "$APP_DIR/.env"
    log ".env file copied from /tmp/frontend.env"
elif [ -f "/tmp/frontend.env.template" ] && [ -n "$VITE_API_URL" ]; then
    # Generate .env file from template if provided
    log "Generating .env file from template..."
    envsubst < /tmp/frontend.env.template > "$APP_DIR/.env"
    log ".env file generated from template"
else
    log "WARNING: No .env file or template found. You may need to create .env manually."
    log "Required variables: VITE_API_URL, VITE_SUPABASE_URL, VITE_SUPABASE_ANON_KEY"
fi

# Step 9: Build frontend
log "Step 9: Building frontend application..."
npm run build:client >> "$LOG_FILE" 2>&1
log "Frontend built successfully"

# Step 10: Copy build output to Nginx web root
log "Step 10: Copying build files to Nginx web root..."
sudo mkdir -p "$NGINX_ROOT"
sudo cp -r "$APP_DIR/dist"/* "$NGINX_ROOT/"
sudo chown -R nginx:nginx "$NGINX_ROOT"
log "Build files copied to $NGINX_ROOT"

# Step 11: Configure Nginx for frontend (SPA routing)
log "Step 11: Configuring Nginx..."
sudo tee "$NGINX_CONFIG" > /dev/null <<EOF
server {
    listen 80;
    server_name _;
    root $NGINX_ROOT;
    index index.html;

    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css text/xml text/javascript application/javascript application/xml+rss application/json;

    # SPA routing - serve index.html for all routes
    location / {
        try_files \$uri \$uri/ /index.html;
    }

    # Cache static assets
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
}
EOF

log "Nginx configuration created at $NGINX_CONFIG"

# Step 12: Test Nginx configuration and start service
log "Step 12: Testing Nginx configuration..."
sudo nginx -t >> "$LOG_FILE" 2>&1

log "Starting and enabling Nginx..."
sudo systemctl enable nginx
sudo systemctl restart nginx

# Step 13: Wait for Nginx to start
log "Step 13: Waiting for Nginx to start..."
sleep 5

# Step 14: Verify frontend is accessible
log "Step 14: Verifying frontend is accessible..."
MAX_RETRIES=10
RETRY_COUNT=0

while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
    if curl -f http://localhost/ >> "$LOG_FILE" 2>&1; then
        log "✅ Frontend is accessible!"
        break
    else
        RETRY_COUNT=$((RETRY_COUNT + 1))
        log "Waiting for frontend to be ready... ($RETRY_COUNT/$MAX_RETRIES)"
        sleep 2
    fi
done

if [ $RETRY_COUNT -eq $MAX_RETRIES ]; then
    log "❌ Frontend verification failed after $MAX_RETRIES attempts"
    exit 1
fi

log "=========================================="
log "Frontend Deployment Completed Successfully!"
log "=========================================="
log "Application Directory: $APP_DIR"
log "Nginx Web Root: $NGINX_ROOT"
log "Frontend URL: http://localhost"
log "Log File: $LOG_FILE"

