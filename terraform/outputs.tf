output "app_name" {
  description = "Deployed application name"
  value       = kubernetes_deployment.app.metadata[0].name
}

output "replicas" {
  description = "Number of running replicas"
  value       = kubernetes_deployment.app.spec[0].replicas
}

output "service_type" {
  description = "Service type"
  value       = kubernetes_service.app.spec[0].type
}
