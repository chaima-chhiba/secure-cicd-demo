variable "app_name" {
  description = "Application name"
  default     = "secure-cicd-demo"
}

variable "replicas" {
  description = "Number of pod replicas"
  default     = 2
}

variable "image" {
  description = "Docker image to deploy"
  default     = "chaimachhiba/secure-cicd-demo:latest"
}
