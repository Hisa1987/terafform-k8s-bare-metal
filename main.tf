terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.5.0"
    }
  }
}

provider "kubernetes" {
  config_path  = "~/.kube/config"
  # Configuration options
}

resource "kubernetes_namespace" "test" {
  metadata {
    name = "test"
  }
}

resource "kubernetes_limit_range" "test" {
  metadata {
    name      = "test-limit-range"
    namespace = kubernetes_namespace.test.metadata[0].name
  }

  spec {
    limit {
      type = "Container"

      default = {
        memory = "512Mi"
        cpu    = "500m"
      }

      default_request = {
        memory = "256Mi"
        cpu    = "100m"
      }
    }
  }
}

resource "kubernetes_role" "test" {
  metadata {
    name      = "test-role"
    namespace = kubernetes_namespace.test.metadata[0].name
  }

  rule {
    api_groups = [""]
    resources  = ["pods"]
    verbs      = ["get", "list", "watch", "create", "update", "patch", "delete"]
  }
}

resource "kubernetes_role_binding" "test" {
  metadata {
    name      = "test-role-binding"
    namespace = kubernetes_namespace.test.metadata[0].name
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.test.metadata[0].name
  }

  subject {
    kind      = "User"
    name      = "test-user"
    api_group = "rbac.authorization.k8s.io"
  }
}
