resource "kubernetes_namespace" "homepage" {
  metadata {
    name = "homepage"
  }
}

# Unofficial helm chart: https://github.com/gethomepage/homepage/blob/main/kubernetes.md
resource "helm_release" "homepage" {
  name       = "homepage"
  namespace  = kubernetes_namespace.homepage.metadata[0].name
  chart      = "homepage"
  repository = "https://jameswynn.github.io/helm-charts"
  values = [file("config/homepage/helm-values.yaml")]

  depends_on = [kubernetes_namespace.homepage]
}


resource "kubernetes_manifest" "homepage_certificate" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name      = "homepage-ingressroute-certificate"
      namespace = "homepage"
    }
    spec = {
      secretName = "homepage-certificate-secret"
      issuerRef = {
        name = "cloudflare-clusterissuer"
        kind = "ClusterIssuer"
      }
      dnsNames = ["homepage.andywebservices.com"]
    }
  }

  depends_on = [helm_release.homepage, kubernetes_manifest.cloudflare_clusterissuer]
}

resource "kubernetes_manifest" "homepage_ingressroute" {
  manifest = {
    apiVersion = "traefik.io/v1alpha1"
    kind       = "IngressRoute"
    metadata = {
      name      = "homepage-ingressroute"
      namespace = "homepage"
    }
    spec = {
      entryPoints = ["websecure"]
      routes = [
        {
          match = "Host(`homepage.andywebservices.com`)"
          kind  = "Rule"
          services = [
            {
              name = "homepage"
              port = 3000
            }
          ]
        }
      ]
      tls = {
        secretName = "homepage-certificate-secret"
      }
    }
  }
  depends_on = [kubernetes_namespace.homepage, kubernetes_manifest.cloudflare_clusterissuer, helm_release.traefik]
}
