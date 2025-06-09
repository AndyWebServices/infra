resource "kubernetes_namespace" "karakeep" {
  metadata {
    name = "karakeep"
  }
}

resource "kubernetes_config_map" "karakeep_configuration" {
  metadata {
    name      = "karakeep-configuration"
    namespace = kubernetes_namespace.karakeep.metadata[0].name
  }

  data = {
    KARAKEEP_VERSION = "release"
    NEXTAUTH_URL     = "http://localhost:3000"
  }
}

resource "kubernetes_secret" "karakeep_secrets" {
  metadata {
    name      = "karakeep-secrets"
    namespace = kubernetes_namespace.karakeep.metadata[0].name
  }

  data = {
    MEILI_MASTER_KEY   = var.meili_master_key
    NEXT_PUBLIC_SECRET = var.next_public_secret
    NEXTAUTH_SECRET    = var.nextauth_secret
  }

  type = "Opaque"
}

resource "kubernetes_service" "chrome" {
  metadata {
    name      = "chrome"
    namespace = kubernetes_namespace.karakeep.metadata[0].name
  }

  spec {
    selector = {
      app = "chrome"
    }

    port {
      port        = 9222
      target_port = 9222
      protocol    = "TCP"
    }

    type = "ClusterIP"
  }
}

resource "kubernetes_service" "meilisearch" {
  metadata {
    name      = "meilisearch"
    namespace = kubernetes_namespace.karakeep.metadata[0].name
  }

  spec {
    selector = {
      app = "meilisearch"
    }

    port {
      port        = 7700
      target_port = 7700
      protocol    = "TCP"
    }

    # type = "ClusterIP"  # Optional, ClusterIP is the default
  }
}

resource "kubernetes_service" "web" {
  metadata {
    name      = "web"
    namespace = kubernetes_namespace.karakeep.metadata[0].name
    annotations = {
      "kube-vip.io/loadbalancerIPs" = "192.168.0.61"
      "kube-vip.io/vipHost"         = "rpi0"
    }
    labels = {
      "implementation" = "kube-vip"
    }
  }

  spec {
    selector = {
      app = "karakeep-web"
    }
    load_balancer_ip = "192.168.0.61"

    port {
      port        = 3000
      target_port = 3000
      protocol    = "TCP"
    }

    type = "LoadBalancer"
  }
}

resource "kubernetes_persistent_volume_claim" "data_pvc" {
  metadata {
    name      = "data-pvc"
    namespace = kubernetes_namespace.karakeep.metadata[0].name
  }

  spec {
    access_modes = ["ReadWriteOnce"]

    resources {
      requests = {
        storage = "1Gi"
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "meilisearch_pvc" {
  metadata {
    name      = "meilisearch-pvc"
    namespace = kubernetes_namespace.karakeep.metadata[0].name
  }

  spec {
    access_modes = ["ReadWriteOnce"]

    resources {
      requests = {
        storage = "1Gi"
      }
    }
  }
}

resource "kubernetes_deployment" "chrome" {
  metadata {
    name      = "chrome"
    namespace = kubernetes_namespace.karakeep.metadata[0].name
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "chrome"
      }
    }

    template {
      metadata {
        labels = {
          app = "chrome"
        }
      }

      spec {
        container {
          name  = "chrome"
          image = "gcr.io/zenika-hub/alpine-chrome:123"

          command = [
            "chromium-browser",
            "--headless",
            "--no-sandbox",
            "--disable-gpu",
            "--disable-dev-shm-usage",
            "--remote-debugging-address=0.0.0.0",
            "--remote-debugging-port=9222",
            "--hide-scrollbars",
          ]
        }
      }
    }
  }
}

resource "kubernetes_deployment" "meilisearch" {
  metadata {
    name      = "meilisearch"
    namespace = kubernetes_namespace.karakeep.metadata[0].name
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "meilisearch"
      }
    }

    template {
      metadata {
        labels = {
          app = "meilisearch"
        }
      }

      spec {
        container {
          name  = "meilisearch"
          image = "getmeili/meilisearch:v1.11.1"

          env {
            name  = "MEILI_NO_ANALYTICS"
            value = "true"
          }

          env_from {
            secret_ref {
              name = kubernetes_secret.karakeep_secrets.metadata[0].name
            }
          }

          env_from {
            config_map_ref {
              name = kubernetes_config_map.karakeep_configuration.metadata[0].name
            }
          }

          volume_mount {
            name       = "meilisearch"
            mount_path = "/meili_data"
          }
        }

        volume {
          name = "meilisearch"

          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.meilisearch_pvc.metadata[0].name
          }
        }
      }
    }
  }
}

resource "kubernetes_deployment" "web" {
  metadata {
    name      = "web"
    namespace = kubernetes_namespace.karakeep.metadata[0].name
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "karakeep-web"
      }
    }

    template {
      metadata {
        labels = {
          app = "karakeep-web"
        }
      }

      spec {
        container {
          name              = "web"
          image             = "ghcr.io/karakeep-app/karakeep:release"
          image_pull_policy = "Always"

          env {
            name  = "MEILI_ADDR"
            value = "http://meilisearch:7700"
          }

          env {
            name  = "BROWSER_WEB_URL"
            value = "http://chrome:9222"
          }

          env {
            name  = "DATA_DIR"
            value = "/data"
          }

          env {
            name  = "DISABLE_SIGNUPS"
            value = "true"
          }

          env {
            name = "OLLAMA_BASE_URL"
            value = "http://192.168.0.44:11434"
          }

          env {
            name = "INFERENCE_TEXT_MODEL"
            value = "mistral"
          }

          env {
            name = "INFERENCE_IMAGE_MODEL"
            value = "llava"
          }

          env_from {
            secret_ref {
              name = kubernetes_secret.karakeep_secrets.metadata[0].name
            }
          }

          env_from {
            config_map_ref {
              name = kubernetes_config_map.karakeep_configuration.metadata[0].name
            }
          }

          port {
            container_port = 3000
          }

          volume_mount {
            name       = "data"
            mount_path = "/data"
          }
        }

        volume {
          name = "data"

          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.data_pvc.metadata[0].name
          }
        }
      }
    }
  }
}

resource "kubernetes_manifest" "karakeep_certificate" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name      = "karakeep-ingressroute-certificate"
      namespace = kubernetes_namespace.karakeep.metadata[0].name
    }
    spec = {
      secretName = "karakeep-certificate-secret"
      issuerRef = {
        name = kubernetes_manifest.cloudflare_clusterissuer.manifest.metadata.name
        kind = "ClusterIssuer"
      }
      dnsNames = [
        "karakeep.andywebservices.com"
      ]
    }
  }
}

resource "kubernetes_manifest" "karakeep_ingressroute" {
  manifest = {
    apiVersion = "traefik.io/v1alpha1"
    kind       = "IngressRoute"
    metadata = {
      name      = "karakeep-ingressroute"
      namespace = kubernetes_namespace.karakeep.metadata[0].name
    }
    spec = {
      entryPoints = ["websecure"]
      routes = [
        {
          match = "Host(`karakeep.andywebservices.com`)"
          kind  = "Rule"
          services = [
            {
              name = "web"
              port = 3000
            }
          ]
        }
      ]
      tls = {
        secretName = kubernetes_manifest.karakeep_certificate.manifest.spec.secretName
      }
    }
  }
  depends_on = [
    helm_release.traefik
  ]
}

