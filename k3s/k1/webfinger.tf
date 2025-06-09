resource "kubernetes_namespace" "webfinger" {
  metadata {
    name = "webfinger"
  }
}

resource "kubernetes_persistent_volume_claim" "webfinger_pvc" {
  metadata {
    name      = "webfinger-pvc"
    namespace = kubernetes_namespace.webfinger.metadata[0].name
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


resource "kubernetes_deployment" "webfinger" {
  metadata {
    name      = "webfinger"
    namespace = kubernetes_namespace.webfinger.metadata[0].name

  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "webfinger"
      }
    }

    template {
      metadata {
        labels = {
          app = "webfinger"
        }
      }

      spec {
        container {
          name  = "webfinger"
          image = "nginx"

          volume_mount {
            name       = "webfinger-html"
            mount_path = "/usr/share/nginx/html"
          }
        }
        volume {
          name = "webfinger-html"

          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.webfinger_pvc.metadata[0].name
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "webfinger" {
  metadata {
    name      = "webfinger"
    namespace = kubernetes_namespace.webfinger.metadata[0].name
  }

  spec {
    selector = {
      app = "webfinger"
    }
    port {
      port        = 80
      target_port = 80
      protocol    = "TCP"
    }
    type = "ClusterIP"
  }
}

resource "kubernetes_manifest" "webfinger_certificate" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name      = "webfinger-ingressroute-certificate"
      namespace = kubernetes_namespace.webfinger.metadata[0].name
    }
    spec = {
      secretName = "webfinger-certificate-secret"
      issuerRef = {
        name = kubernetes_manifest.cloudflare_clusterissuer.manifest.metadata.name
        kind = "ClusterIssuer"
      }
      dnsNames = [
        "andywebservices.com"
      ]
    }
  }
}

resource "kubernetes_manifest" "webfinger_ingressroute" {
  manifest = {
    apiVersion = "traefik.io/v1alpha1"
    kind       = "IngressRoute"
    metadata = {
      name      = "webfinger-ingressroute"
      namespace = kubernetes_namespace.webfinger.metadata[0].name
    }
    spec = {
      entryPoints = ["websecure"]
      routes = [
        {
          match = "Host(`andywebservices.com`)"
          kind  = "Rule"
          services = [
            {
              name = "webfinger"
              port = 80
            }
          ]
        }
      ]
      tls = {
        secretName = kubernetes_manifest.webfinger_certificate.manifest.spec.secretName
      }
    }
  }
  depends_on = [
    helm_release.traefik
  ]
}

