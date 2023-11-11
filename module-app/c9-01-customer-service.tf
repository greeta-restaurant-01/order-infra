resource "kubernetes_config_map_v1" "customer" {
  metadata {
    name      = "customer"
    labels = {
      app = "customer"
    }
  }

  data = {
    "application.yml" = file("${path.module}/app-conf/customer.yml")
  }
}

resource "kubernetes_deployment_v1" "customer_deployment" {
  depends_on = [kubernetes_deployment_v1.order_postgres_deployment]
  metadata {
    name = "customer"
    labels = {
      app = "customer"
    }
  }
 
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "customer"
      }
    }
    template {
      metadata {
        labels = {
          app = "customer"
        }
        annotations = {
          "prometheus.io/scrape" = "true"
          "prometheus.io/path"   = "/actuator/prometheus"
          "prometheus.io/port"   = "8080"
        }        
      }
      spec {
        service_account_name = "spring-cloud-kubernetes"      
        
        container {
<<<<<<< HEAD:module-app/c9-01-customer-service.tf
          image = "ghcr.io/greeta-restaurant-01/customer-service:7f03518833641f74c45a1fbbe91bcb7d58470a00"
          name  = "customer"
=======
          image = "ghcr.io/greeta-bookshop-01/catalog-service:2180d36e79a9dfa7dd48bc4fe370ea97b069cbdd"
          name  = "catalog"
>>>>>>> refs/remotes/origin/master:module-app/c9-01-catalog-service.tf
          image_pull_policy = "Always"
          port {
            container_port = 8080
          }  
          port {
            container_port = 8001
          } 

          env {
            name  = "SPRING_CLOUD_BOOTSTRAP_ENABLED"
            value = "true"
          }

          env {
            name  = "SPRING_CLOUD_KUBERNETES_SECRETS_ENABLEAPI"
            value = "true"
          }

          env {
            name  = "JAVA_TOOL_OPTIONS"
            value = "-javaagent:/workspace/BOOT-INF/lib/opentelemetry-javaagent-1.17.0.jar"
          }

          env {
            name  = "OTEL_SERVICE_NAME"
            value = "customer"
          }

          env {
            name  = "OTEL_EXPORTER_OTLP_ENDPOINT"
            value = "http://tempo.observability-stack.svc.cluster.local:4317"
          }

          env {
            name  = "OTEL_METRICS_EXPORTER"
            value = "none"
          }

          env {
            name  = "BPL_JVM_THREAD_COUNT"
            value = "50"
          }

          env {
            name  = "BPL_DEBUG_ENABLED"
            value = "true"
          }

          env {
            name  = "BPL_DEBUG_PORT"
            value = "8001"
          }       
          

          # resources {
          #   requests = {
          #     memory = "756Mi"
          #     cpu    = "0.1"
          #   }
          #   limits = {
          #     memory = "756Mi"
          #     cpu    = "2"
          #   }
          # }          

          lifecycle {
            pre_stop {
              exec {
                command = ["sh", "-c", "sleep 5"]
              }
            }
          }

          # liveness_probe {
          #   http_get {
          #     path = "/actuator/health/liveness"
          #     port = 8080
          #   }
          #   initial_delay_seconds = 120
          #   period_seconds        = 15
          # }

          # readiness_probe {
          #   http_get {
          #     path = "/actuator/health/readiness"
          #     port = 8080
          #   }
          #   initial_delay_seconds = 20
          #   period_seconds        = 15
          # }  
         
        }
      }
    }
  }
}

resource "kubernetes_horizontal_pod_autoscaler_v1" "customer_hpa" {
  metadata {
    name = "customer-hpa"
  }
  spec {
    max_replicas = 2
    min_replicas = 1
    scale_target_ref {
      api_version = "apps/v1"
      kind = "Deployment"
      name = kubernetes_deployment_v1.customer_deployment.metadata[0].name 
    }
    target_cpu_utilization_percentage = 70
  }
}

resource "kubernetes_service_v1" "customer_service" {
  depends_on = [kubernetes_deployment_v1.customer_deployment]
  metadata {
    name = "customer"
    labels = {
      app = "customer"
      spring-boot = "true"
    }
  }
  spec {
    selector = {
      app = "customer"
    }
    port {
      name = "prod"
      port = 8080
    }
    port {
      name = "debug"
      port = 8001
    }    
  }
}