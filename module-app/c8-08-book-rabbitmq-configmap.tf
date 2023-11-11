 # Resource: Config Map
resource "kubernetes_config_map_v1" "book_rabbitmq_config_map" {
  metadata {
    name = "book-rabbitmq-dbcreation-script"
    labels = {
      db = "book-rabbitmq"
    }
  }

  data = {
    "rabbitmq.conf" = <<EOF
      default_user = user
      default_pass = password
      vm_memory_high_watermark.relative = 1.0
    EOF
  }
}