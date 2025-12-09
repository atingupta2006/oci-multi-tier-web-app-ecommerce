#cloud-config
#
# NOTE: This cloud-init file is DEPRECATED.
# The backend deployment now uses the Systemd-based cloud-init
# defined as a heredoc within the instance-pool-autoscaling.tf file.
# This prevents conflicts with the Instance Pool lifecycle and
# ensures a clean Systemd service is used instead of PM2.
#
#######################################################################
# PM2-BASED CONFIGURATION (COMMENTED OUT/REMOVED TO PREVENT CONFLICTS)
#######################################################################
# package_update: true
# package_upgrade: true

# write_files:
#   # 1. Write backend .env (Base64 decoded)
#   - path: /opt/bharatmart/.env
#     permissions: "0644"
#     owner: opc:opc
#     encoding: b64
#     content: ${app_env_b64}

#   # 2. UMA Prometheus config (bm_ prefix applied)
#   - path: /opt/oracle-cloud-agent/plugins/monitoring/prometheus-config.json
#     permissions: "0644"
#     owner: root:root
#     encoding: b64
#     content: ${backend_uma_prom_config_b64}

# runcmd:
#   # SYSTEM PREP (Node.js install, git, build tools)
#   - yum install -y git gcc-c++ make || true

#   # Install Node.js 20.x (stable, GPG handled)
#   - curl -fsSL https://rpm.nodesource.com/setup_20.x | bash -
#   - yum install -y nodejs --nogpgcheck || yum install -y nodejs

#   # CREATE APPLICATION DIRECTORY
#   - mkdir -p /opt/bharatmart
#   - chown -R opc:opc /opt/bharatmart

#   # CLONE GITHUB REPO ON FIRST BOOT (Idempotent)
#   - |
#     if [ ! -d /opt/bharatmart/.git ]; then
#       git clone --branch main --depth 1 ${var.github_repo_url} /opt/bharatmart
#       chown -R opc:opc /opt/bharatmart
#     fi

#   # INSTALL BACKEND DEPENDENCIES
#   - su - opc -c "cd /opt/bharatmart && npm install"

#   # BUILD BACKEND SERVER (TypeScript → JS)
#   - su - opc -c "cd /opt/bharatmart && npm run build:server"

#   # INSTALL AND RUN PM2
#   - npm install -g pm2

#   # Remove previous instances (Node.js auto restart safe)
#   - su - opc -c "pm2 delete bharatmart-backend || true"

#   - mkdir -p /opt/bharatmart/logs
#   - chown opc:opc /opt/bharatmart/logs

#   # Start backend from compiled output
#   - su - opc -c "cd /opt/bharatmart && pm2 start dist/server/index.js --name bharatmart-backend"

#   # Persist PM2 state across reboots
#   - su - opc -c "pm2 save"

#   # ENABLE ALL OCI UMA PLUGINS (Logging + Monitoring + Trace)
#   - systemctl restart oracle-cloud-agent || true