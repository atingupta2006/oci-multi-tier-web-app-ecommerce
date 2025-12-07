#!/bin/bash
# BharatMart Backend Deployment Script
# This script is executed on the backend VM via Terraform provisioner

set -e
set -x

# Configuration Variables (can be overridden by environment variables)
APP_DIR="${BACKEND_APP_DIR:-/opt/bharatmart-backend}"
REPO_URL="${REPO_URL:-https://github.com/atingupta2006/oci-multi-tier-web-app-ecommerce.git}"
REPO_BRANCH="${REPO_BRANCH:-main}"
NODE_VERSION="20"
USE_PM2="${USE_PM2:-true}"

# Log file for deployment
LOG_FILE="/var/log/bharatmart-backend-deployment.log"

# Logging function
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

log "=========================================="
log "Starting BharatMart Backend Deployment"
log "=========================================="

# Step 1: System Update
log "Step 1: Updating system packages..."
sudo yum update -y >> "$LOG_FILE" 2>&1

# Step 2: Install Node.js 20
log "Step 2: Installing Node.js ${NODE_VERSION}..."
if ! command -v node &> /dev/null; then
    curl -fsSL https://rpm.nodesource.com/setup_${NODE_VERSION}.x | sudo bash - >> "$LOG_FILE" 2>&1
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

# Step 4: Install PM2 (if using PM2)
if [ "$USE_PM2" = "true" ]; then
    log "Step 4: Installing PM2..."
    if ! command -v pm2 &> /dev/null; then
        sudo npm install -g pm2 >> "$LOG_FILE" 2>&1
        log "PM2 installed: $(pm2 --version)"
    else
        log "PM2 already installed: $(pm2 --version)"
    fi
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
if [ -f "/tmp/backend.env" ]; then
    # Use uploaded .env file if available
    cp /tmp/backend.env "$APP_DIR/.env"
    log ".env file copied from /tmp/backend.env"
elif [ -f "/tmp/backend.env.template" ] && [ -n "$SUPABASE_URL" ]; then
    # Generate .env file from template if provided
    log "Generating .env file from template..."
    envsubst < /tmp/backend.env.template > "$APP_DIR/.env"
    log ".env file generated from template"
else
    log "WARNING: No .env file or template found. You may need to create .env manually."
    log "Required variables: SUPABASE_URL, SUPABASE_ANON_KEY, SUPABASE_SERVICE_ROLE_KEY, JWT_SECRET, etc."
fi

# Step 9: Create logs directory
log "Step 9: Creating logs directory..."
mkdir -p "$APP_DIR/logs"
log "Logs directory created"

# Step 10: Initialize database
log "Step 10: Initializing database..."
npm run db:init >> "$LOG_FILE" 2>&1 || log "WARNING: Database initialization failed or already initialized"

# Step 11: Build backend
log "Step 11: Building backend application..."
npm run build:server >> "$LOG_FILE" 2>&1
log "Backend built successfully"

# Step 12: Setup service (PM2 or systemd)
log "Step 12: Setting up backend service..."

if [ "$USE_PM2" = "true" ]; then
    # PM2 Setup
    log "Using PM2 for process management..."
    
    # Stop existing PM2 process if running
    pm2 delete bharatmart-backend 2>/dev/null || true
    
    # Start backend with PM2
    cd "$APP_DIR"
    pm2 start npm --name "bharatmart-backend" -- start:server >> "$LOG_FILE" 2>&1
    
    # Save PM2 configuration
    pm2 save >> "$LOG_FILE" 2>&1
    
    # Setup PM2 to start on boot
    pm2 startup systemd -u opc --hp /home/opc | sudo bash >> "$LOG_FILE" 2>&1 || true
    
    log "Backend started with PM2"
else
    # Systemd Setup
    log "Using systemd for process management..."
    
    # Create systemd service file
    sudo tee /etc/systemd/system/bharatmart-backend.service > /dev/null <<EOF
[Unit]
Description=BharatMart Backend API Service
After=network.target

[Service]
Type=simple
User=opc
WorkingDirectory=$APP_DIR
EnvironmentFile=$APP_DIR/.env
ExecStart=/usr/bin/node $APP_DIR/dist/server/index.js
Restart=always
RestartSec=10
StandardOutput=append:$APP_DIR/logs/backend.log
StandardError=append:$APP_DIR/logs/backend.error.log

[Install]
WantedBy=multi-user.target
EOF
    
    # Reload systemd and enable service
    sudo systemctl daemon-reload
    sudo systemctl enable bharatmart-backend
    sudo systemctl restart bharatmart-backend
    
    log "Backend service created and started"
fi

# Step 13: Wait for service to start
log "Step 13: Waiting for backend service to start..."
sleep 10

# Step 14: Verify health endpoint
log "Step 14: Verifying backend health..."
MAX_RETRIES=30
RETRY_COUNT=0

while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
    if curl -f http://localhost:3000/api/health >> "$LOG_FILE" 2>&1; then
        log "✅ Backend health check passed!"
        break
    else
        RETRY_COUNT=$((RETRY_COUNT + 1))
        log "Waiting for backend to be ready... ($RETRY_COUNT/$MAX_RETRIES)"
        sleep 5
    fi
done

if [ $RETRY_COUNT -eq $MAX_RETRIES ]; then
    log "❌ Backend health check failed after $MAX_RETRIES attempts"
    exit 1
fi

log "=========================================="
log "Backend Deployment Completed Successfully!"
log "=========================================="
log "Application Directory: $APP_DIR"
log "Backend URL: http://localhost:3000"
log "Health Check: http://localhost:3000/api/health"
log "Log File: $LOG_FILE"

