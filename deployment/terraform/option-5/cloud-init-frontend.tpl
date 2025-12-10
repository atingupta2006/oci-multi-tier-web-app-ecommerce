#cloud-config
package_update: true
package_upgrade: true

write_files:
  ###########################################################################
  # 1. Write frontend .env file (Base64 decoded by Terraform)
  ###########################################################################
  - path: /opt/bharatmart-frontend/.env
    permissions: "0644"
    owner: opc:opc
    encoding: b64
    content: ${app_env_b64}

  ###########################################################################
  # 2. UMA Logging Config → Ship NGINX logs to OCI Logging
  ###########################################################################
  - path: /opt/oracle-cloud-agent/plugins/logging/config.json
    owner: root:root
    permissions: "0644"
    encoding: b64
    content: ${frontend_cloud_agent_config_b64}

runcmd:
  ###########################################################################
  # Install NGINX + Git
  ###########################################################################
  - yum install -y nginx git || true

  ###########################################################################
  # Create application directory
  ###########################################################################
  - mkdir -p /opt/bharatmart-frontend
  - chown -R opc:opc /opt/bharatmart-frontend

  ###########################################################################
  # Clone frontend repo (idempotent)
  ###########################################################################
  - |
    if [ ! -d /opt/bharatmart-frontend/.git ]; then
      git clone --branch main --depth 1 ${var.github_repo_url} /opt/bharatmart-frontend
      chown -R opc:opc /opt/bharatmart-frontend
    fi

  ###########################################################################
  # Disable OS Firewalls (CRITICAL FIX for LB/Public Connectivity)
  ###########################################################################
  - systemctl stop firewalld || true
  - systemctl disable firewalld || true
  - systemctl stop nftables || true
  - systemctl disable nftables || true

  ###########################################################################
  # Install Node.js (CRITICAL FIX — must be combined into one YAML block)
  ###########################################################################
  - |
    # Combined commands for cloud-init YAML correctness
    curl -fsSL https://rpm.nodesource.com/setup_20.x | bash -
    yum install -y nodejs --nogpgcheck || yum install -y nodejs

  ###########################################################################
  # Install dependencies + Build frontend (Vite)
  ###########################################################################
  - su - opc -c "cd /opt/bharatmart-frontend && npm install"
  - su - opc -c "cd /opt/bharatmart-frontend && . ./.env && npm run build"

  # === DEBUGGING: BUILD CHECK ===
  - echo "### DEBUG: BUILD CHECK ###"
  - echo "# Attempting to show .env file content (will be silent if file is missing):"
  - cat /opt/bharatmart-frontend/.env 2>/dev/null || true
  - echo "# Check build output existence (run this command manually):"
  - echo "# ls -l /opt/bharatmart-frontend/dist/index.html"

  ###########################################################################
  # Copy Vite build output to NGINX
  ###########################################################################
  - rm -rf /usr/share/nginx/html/*
  - cp -r /opt/bharatmart-frontend/dist/* /usr/share/nginx/html/
  - chown -R nginx:nginx /usr/share/nginx/html

  ###########################################################################
  # Configure NGINX for SPA routing (critical for Vite)
  ###########################################################################
  - |
    cat > /etc/nginx/conf.d/bharatmart-frontend.conf << 'EOF'
    server {
        listen 80 default_server;
        server_name _;

        root /usr/share/nginx/html;
        index index.html;

        access_log /var/log/nginx/access.log;
        error_log  /var/log/nginx/error.log;

        location / {
            try_files $uri /index.html;
        }
    }
    EOF

  ###########################################################################
  # Enable & restart NGINX
  ###########################################################################
  - systemctl enable nginx
  - systemctl restart nginx


  # === DEBUGGING: NGINX CHECK ===
  - echo "### DEBUG: NGINX CHECK ###"
  - echo "# Check NGINX Status:"
  - echo "# sudo systemctl status nginx"
  - echo "# Check Local Health (should return HTML):"
  - echo "# curl http://localhost"
  - echo "# View NGINX Error Log for failures:"
  - echo "# sudo cat /var/log/nginx/error.log"


  ###########################################################################
  # Restart Cloud Agent to load UMA logging config
  ###########################################################################
  - systemctl restart oracle-cloud-agent || true


  # === DEBUGGING: OBSERVABILITY CHECK ===
  - echo "### DEBUG: AGENT CHECK ###"
  - echo "# Check Agent Status:"
  - echo "# sudo systemctl status oracle-cloud-agent"
  - echo "# Verify Logging Config file (check paths and Log IDs):"
  - echo "# sudo cat /opt/oracle-cloud-agent/plugins/logging/config.json"