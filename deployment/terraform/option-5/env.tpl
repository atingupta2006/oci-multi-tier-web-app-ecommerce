############################################################
# env.tpl – BharatMart Backend + Frontend Environment Template
# Automatically rendered by Terraform
############################################################

###############################
# GENERAL RUNTIME SETTINGS
###############################
NODE_ENV=production
DEPLOYMENT_MODE=oci

PORT=3000
HOST=0.0.0.0

FRONTEND_URL=http://${lb_ip}
CORS_ORIGIN=*


############################################################
# DATABASE — Supabase
############################################################
DATABASE_TYPE=supabase
SUPABASE_URL=${supabase_url}
SUPABASE_ANON_KEY=${supabase_anon_key}
SUPABASE_SERVICE_ROLE_KEY=${supabase_service_role_key}


############################################################
# AUTHENTICATION
############################################################
AUTH_PROVIDER=supabase
JWT_SECRET=${jwt_secret}


############################################################
# ADMIN SEEDING
############################################################
ADMIN_EMAIL=${admin_email}
ADMIN_PASSWORD=${admin_password}


############################################################
# CACHE
############################################################
CACHE_TYPE=memory


############################################################
# LOGGING CONFIGURATION (CLOUD AGENT FRIENDLY)
############################################################
LOG_LEVEL=info
LOG_FORMAT=json

# OCI Cloud Agent reads JSON logs from this file
LOG_FILE=/opt/bharatmart/logs/api.log

# This enables full structured logs such as:
#  {
#    "timestamp": "...",
#    "level": "info",
#    "msg": "Order created",
#    "order_id": 123
#  }


############################################################
# PROMETHEUS METRICS EXPORTER (PER INSTANCE)
############################################################
ENABLE_METRICS=true

# All exported metric names will be prefixed with: bm_
# Example:
#   http_requests_total → bm_http_requests_total
#   http_request_duration_seconds_bucket → bm_http_request_duration_bucket


############################################################
# OTEL TRACING CONFIGURATION (EXPORT TO OCI)
############################################################
# Service identifiers
OTEL_SERVICE_NAME=bharatmart-backend
OTEL_RESOURCE_ATTRIBUTES=service.name=bharatmart-backend,service.namespace=bharatmart,deployment.environment=production

# Always sample traces (good for training/demo; reduce in production)
OTEL_TRACES_SAMPLER=always_on

# The backend OTEL collector runs locally on port 4318
# (Forwarding is handled by OCI Cloud Agent or collector)
OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4318/v1/traces

# OTEL Export Format
OTEL_EXPORTER_OTLP_PROTOCOL=http/protobuf


############################################################
# FRONTEND VITE BUILD CONFIG
############################################################
VITE_API_URL=http://${lb_ip}:3000
VITE_APP_NAME=BharatMart
VITE_SUPABASE_URL=${supabase_url}
VITE_SUPABASE_ANON_KEY=${supabase_anon_key}


############################################################
# WORKERS (DISABLED)
############################################################
WORKER_MODE=none
QUEUE_REDIS_URL=


############################################################
# CHAOS MODE (TRAINING ONLY)
############################################################
CHAOS_ENABLED=true
CHAOS_LATENCY_MS=800
