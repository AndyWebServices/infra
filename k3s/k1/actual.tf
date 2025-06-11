resource "kubernetes_namespace" "actual" {
  metadata {
    name = "actual"
  }
}

resource "kubernetes_persistent_volume_claim" "actual" {
  metadata {
    name      = "actual-data-pvc"
    namespace = kubernetes_namespace.actual.metadata[0].name
    labels = {
      "recurring-job-group.longhorn.io/default" = "enabled"
      "recurring-job.longhorn.io/c-svue5v"      = "enabled"
    }
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "10Gi"
      }
    }
  }
}

resource "kubernetes_deployment" "actual" {
  metadata {
    name      = "actual"
    namespace = kubernetes_namespace.actual.metadata[0].name
    labels = {
      app = "actual"
    }
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "actual"
      }
    }
    template {
      metadata {
        labels = {
          app = "actual"
        }
      }
      spec {
        container {
          name  = "actual"
          image = "docker.io/actualbudget/actual-server:latest"

          port {
            container_port = 5006
          }

          volume_mount {
            mount_path = "/data"
            name       = "actual-data"
          }

          liveness_probe {
            exec {
              command = ["node", "src/scripts/health-check.js"]
            }
            initial_delay_seconds = 20
            period_seconds        = 60
            timeout_seconds       = 10
            failure_threshold     = 3
          }
        }
        volume {
          name = "actual-data"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.actual.metadata[0].name
          }
        }
      }
    }
  }
}

resource "kubernetes_manifest" "actual_certificate" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name      = "actual-ingressroute-certificate"
      namespace = kubernetes_namespace.actual.metadata[0].name
    }
    spec = {
      secretName = "actual-certificate-secret"
      issuerRef = {
        name = kubernetes_manifest.cloudflare_clusterissuer.manifest.metadata.name
        kind = "ClusterIssuer"
      }
      dnsNames = ["actual.andywebservices.com"]
    }
  }
}

resource "kubernetes_service" "actual" {
  metadata {
    name      = "actual"
    namespace = kubernetes_namespace.actual.metadata[0].name
  }

  spec {
    selector = {
      app = "actual"
    }

    port {
      port        = 5006
      target_port = 5006
    }

    type = "ClusterIP"
  }
}

resource "kubernetes_manifest" "actual_ingressroute" {
  manifest = {
    apiVersion = "traefik.io/v1alpha1"
    kind       = "IngressRoute"
    metadata = {
      name      = "actual-ingressroute"
      namespace = kubernetes_namespace.actual.metadata[0].name
    }
    spec = {
      entryPoints = ["websecure"]
      routes = [
        {
          match = "Host(`actual.andywebservices.com`)"
          kind  = "Rule"
          services = [
            {
              name = "actual"
              port = kubernetes_service.actual.spec[0].port[0].port
            }
          ]
        }
      ]
      tls = {
        secretName = kubernetes_manifest.actual_certificate.manifest.spec.secretName
      }
    }
  }
}


