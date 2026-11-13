variable "app_name" {
  description = "Application name"
  default     = "secure-cicd-demo"
  type        = string
}

variable "replicas" {
  description = "Number of pod replicas"
  default     = 2
  type        = number
}

variable "image" {
  description = "Docker image to deploy"
  default     = "chaimachhiba/secure-cicd-demo:latest"
  type        = string
}
