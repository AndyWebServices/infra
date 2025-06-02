resource "kubernetes_namespace" "cert-manager" {
  metadata {
    name = "cert-manager"
  }
}

# helm install longhorn
resource "helm_release" "cert-manager" {
  name       = "cert-manager"
  namespace  = "cert-manager"
  chart      = "cert-manager"
  repository = "https://charts.jetstack.io"
  values     = [file("config/cert-manager/helm-values.yaml")]
  set {
    name  = "crds.enabled"
    value = "true"
  }
  depends_on = [kubernetes_namespace.cert-manager]
}

resource "kubernetes_secret" "cloudflare_api_token" {
  metadata {
    name      = "cloudflare-api-token-secret"
    namespace = "cert-manager"
  }
  type = "Opaque"
  data = {
    api-token = var.cloudflare_api_token
  }
  depends_on = [kubernetes_namespace.cert-manager]
}

resource "kubernetes_manifest" "cloudflare_clusterissuer" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
    metadata = {
      name = "cloudflare-clusterissuer"
    }
    spec = {
      acme = {
        email  = "admin@andywebservices.com"
        server = "https://acme-v02.api.letsencrypt.org/directory"
        privateKeySecretRef = {
          name = "cloudflare-clusterissuer-account-key"
        }
        solvers = [
          {
            dns01 = {
              cloudflare = {
                apiTokenSecretRef = {
                  name = "cloudflare-api-token-secret"
                  key  = "api-token"
                }
              }
            }
          }
        ]
      }
    }
  }
  depends_on = [kubernetes_namespace.cert-manager, kubernetes_secret.cloudflare_api_token]
}
