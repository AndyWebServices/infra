resource "kubernetes_namespace" "tailscale" {
  metadata {
    name = "tailscale"
  }
}

# Install tailscale operator
resource "helm_release" "tailscale" {
  name       = "tailscale-operator"
  namespace  = kubernetes_namespace.tailscale.metadata[0].name
  chart      = "tailscale-operator"
  repository = "https://pkgs.tailscale.com/helmcharts"
  set {
    name  = "oauth.clientId"
    value = var.tailscale_client_id
  }
  set {
    name  = "oauth.clientSecret"
    value = var.tailscale_client_secret
  }
}

resource "kubernetes_service" "traefik_ts" {
  metadata {
    name      = "traefik-ts"
    namespace = kubernetes_namespace.traefik.metadata[0].name
  }

  spec {
    type                = "LoadBalancer"
    load_balancer_class = "tailscale"

    selector = {
      "app.kubernetes.io/instance" = "traefik-traefik"
      "app.kubernetes.io/name"     = "traefik"
    }

    port {
      name        = "tailweb"
      port        = 80
      target_port = "tailweb"
    }

    port {
      name        = "tailsecure"
      port        = 443
      target_port = "tailsecure"
    }
  }
  depends_on = [helm_release.tailscale, kubernetes_namespace.traefik]
}

