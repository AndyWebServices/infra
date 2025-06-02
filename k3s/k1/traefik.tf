resource "kubernetes_namespace" "traefik" {
  metadata {
    name = "traefik"
  }
}

# helm install longhorn
resource "helm_release" "traefik" {
  name       = "traefik"
  namespace  = kubernetes_namespace.traefik.metadata[0].name
  chart      = "traefik"
  repository = "https://traefik.github.io/charts"
  values     = [file("config/traefik/helm-values.yaml")]
}

