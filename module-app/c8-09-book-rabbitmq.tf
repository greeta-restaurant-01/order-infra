resource "kubernetes_deployment_v1" "book_rabbitmq_deployment" {
  metadata {
    name = "book-rabbitmq"
    labels = {
      db = "book-rabbitmq"
    }
  }

  spec {
    selector {
      match_labels = {
        db = "book-rabbitmq"
      }
    }

    template {
      metadata {
        labels = {
          db = "book-rabbitmq"
        }
      }

      spec {
        container {
          name  = "book-rabbitmq"
          image = "rabbitmq:3.10-management"

          # resources {
          #   requests = {
          #     cpu    = "100m"
          #     memory = "100Mi"
          #   }
          #   limits = {
          #     cpu    = "200m"
          #     memory = "150Mi"
          #   }
          # }

          volume_mount {
            mount_path = "/etc/rabbitmq"
            name       = "book-rabbitmq-config-volume"
          }
        }

        volume {
          name = "book-rabbitmq-config-volume"

          config_map {
            name = kubernetes_config_map_v1.book_rabbitmq_config_map.metadata.0.name
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "book_rabbitmq" {
  metadata {
    name = "book-rabbitmq"
    labels = {
      db = "book-rabbitmq"
    }
  }

  spec {
    type = "ClusterIP"

    selector = {
      db = "book-rabbitmq"
    }

    port {
      name       = "amqp"
      protocol   = "TCP"
      port       = 5672
      target_port = 5672
    }

    port {
      name       = "management"
      protocol   = "TCP"
      port       = 15672
      target_port = 15672
    }
  }
}

# Resource: Polar RabbitMQ Horizontal Pod Autoscaler
resource "kubernetes_horizontal_pod_autoscaler_v1" "book_rabbitmq_hpa" {
  metadata {
    name = "book-rabbitmq-hpa"
  }
  spec {
    max_replicas = 2
    min_replicas = 1
    scale_target_ref {
      api_version = "apps/v1"
      kind = "Deployment"
      name = kubernetes_deployment_v1.book_rabbitmq_deployment.metadata[0].name
    }
    target_cpu_utilization_percentage = 80
  }
}