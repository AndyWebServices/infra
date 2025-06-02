resource "kubernetes_namespace" "longhorn" {
  metadata {
    name = "longhorn-system"
  }
  depends_on = [helm_release.traefik]
}

# helm install longhorn
resource "helm_release" "longhorn" {
  name       = "longhorn"
  namespace  = kubernetes_namespace.longhorn.metadata[0].name
  chart      = "longhorn"
  repository = "https://charts.longhorn.io"
  values = [file("config/longhorn/helm-values.yaml")]

  depends_on = [kubernetes_namespace.longhorn]
}

resource "kubernetes_manifest" "longhorn_certificate" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name      = "longhorn-ingressroute-certificate"
      namespace = kubernetes_namespace.longhorn.metadata[0].name
    }
    spec = {
      secretName = "longhorn-certificate-secret"
      issuerRef = {
        name = kubernetes_manifest.cloudflare_clusterissuer.manifest.metadata.name
        kind = "ClusterIssuer"
      }
      dnsNames = [
        "longhorn.andywebservices.com"
      ]
    }
  }
  depends_on = [kubernetes_namespace.longhorn, helm_release.longhorn, helm_release.cert-manager]
}

resource "kubernetes_manifest" "longhorn_ingressroute" {
  manifest = {
    apiVersion = "traefik.io/v1alpha1"
    kind       = "IngressRoute"
    metadata = {
      name      = "longhorn-ingressroute"
      namespace = kubernetes_namespace.longhorn.metadata[0].name
    }
    spec = {
      entryPoints = ["tailsecure"]
      routes = [
        {
          match = "Host(`longhorn.andywebservices.com`)"
          kind  = "Rule"
          services = [
            {
              name = "longhorn-frontend"
              port = 80
            }
          ]
        }
      ]
      tls = {
        secretName = kubernetes_manifest.longhorn_certificate.manifest.spec.secretName
      }
    }
  }
  depends_on = [
    kubernetes_namespace.longhorn,
    helm_release.longhorn,
    kubernetes_service.traefik_ts
  ]
}

resource "kubernetes_secret" "cifs" {
  metadata {
    name      = "cifs-secret"
    namespace = "longhorn-system"
  }
  data = {
    CIFS_USERNAME = var.longhorn_backup_cifs_username
    CIFS_PASSWORD = var.longhorn_backup_cifs_password
  }
  type = "Opaque"
}

