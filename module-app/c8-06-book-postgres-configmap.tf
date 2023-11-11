 # Resource: Config Map
 resource "kubernetes_config_map_v1" "book_postgres_config_map" {
   metadata {
     name = "book-postgres-dbcreation-script"
   }
   data = {
    "book-db.sql" = "${file("${path.module}/init-conf/bookdb-init.sql")}"
   }
 }