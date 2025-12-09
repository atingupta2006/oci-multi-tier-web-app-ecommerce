{
  "prometheusConfig": {
    "global": {
      "scrape_interval": "15s",
      "scrape_timeout": "10s"
    },
    "scrapeConfigs": [
      {
        "job_name": "bharatmart-backend",
        "static_configs": [
          {
            "targets": ["localhost:3000"],
            "labels": {
              "instance": "__HOSTNAME__",
              "service": "bharatmart-backend",
              "environment": "production"
            }
          }
        ],
        "metricsPath": "/metrics"
      }
    ],
    "metricNameTransform": {
      "prefix": "bm_"
    }
  }
}
