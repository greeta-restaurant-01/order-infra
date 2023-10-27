resource "helm_release" "bitnami_kafka" {
  name       = "bitnami-kafka"
  repository = "oci://registry-1.docker.io/bitnamicharts/"
  chart      = "kafka"
  version = "23.0.7"

}