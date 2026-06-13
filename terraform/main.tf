terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "minikube"
}

resource "kubernetes_deployment" "app" {
  metadata {
    name = "secure-cicd-demo"
    labels = {
      app = "secure-cicd-demo"
    }
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "secure-cicd-demo"
      }
    }

    template {
      metadata {
        labels = {
          app = "secure-cicd-demo"
        }
      }

      spec {
        container {
          name  = "secure-cicd-demo"
          image = "chaimachhiba/secure-cicd-demo:latest"

          port {
            container_port = 5000
          }

          resources {
            requests = {
              memory = "64Mi"
              cpu    = "250m"
            }
            limits = {
              memory = "128Mi"
              cpu    = "500m"
            }
          }

          liveness_probe {
            http_get {
              path = "/health"
              port = 5000
            }
            initial_delay_seconds = 10
            period_seconds        = 10
          }

          readiness_probe {
            http_get {
              path = "/health"
              port = 5000
            }
            initial_delay_seconds = 5
            period_seconds        = 5
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "app" {
  metadata {
    name = "secure-cicd-demo-service"
  }

  spec {
    selector = {
      app = "secure-cicd-demo"
    }

    type = "NodePort"

    port {
      port        = 80
      target_port = 5000
      node_port   = 30080
    }
  }
}
