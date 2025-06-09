resource "kubernetes_namespace" "openwebui" {
  metadata {
    name = "openwebui"
  }
}

# Install openwebui helm
resource "helm_release" "openwebui" {
  name       = "openwebui"
  namespace  = kubernetes_namespace.openwebui.metadata[0].name
  chart      = "open-webui"
  repository = "https://open-webui.github.io/helm-charts"

  values = [
    yamlencode({
      enableOpenaiApi = false
      ingress = {
        enabled = true
        annotations = {
          "kubernetes.io/ingress.class" = "traefik" # Make sure Traefik sees this
          "cert-manager.io/cluster-issuer"           = kubernetes_manifest.cloudflare_clusterissuer.manifest.metadata.name
          "traefik.ingress.kubernetes.io/router.tls" = "true"
        }
        host = "a1.andywebservices.com"
        tls  = true
      }
      persistence = {
        size = "10Gi"
      }
      ollama = {
        enabled = false
      }
      ollamaUrls = [
        "http://192.168.0.44:11434"
      ]
      sso = {
        enabled      = true
        enableSignup = true
        oidc = {
          enabled      = true
          clientId     = "48b76910-0a02-446f-b016-23d8ef2830be"
          clientSecret = "VWxkQsbg0gF1XOyGbSY5Z4xR4HW9VEVW"
          providerName = "Pocket ID"
          providerUrl  = "https://id.andywebservices.com/.well-known/openid-configuration"
        }
      }
    })
  ]
}
