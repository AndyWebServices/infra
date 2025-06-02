resource "kubernetes_namespace" "ha-dummy" {
  metadata {
    name = "ha-dummy"
  }
  depends_on = [kubernetes_manifest.cloudflare_clusterissuer]
}

resource "kubernetes_manifest" "ha-dummy_certificate" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name      = "ha-dummy-ingressroute-certificate"
      namespace = kubernetes_namespace.ha-dummy.metadata[0].name
    }
    spec = {
      secretName = "ha-dummy-certificate-secret"
      issuerRef = {
        name = kubernetes_manifest.cloudflare_clusterissuer.manifest.metadata.name
        kind = "ClusterIssuer"
      }
      dnsNames = [
        "ha.andywebservices.com"
      ]
    }
  }
  depends_on = [kubernetes_namespace.ha-dummy]
}

resource "kubernetes_manifest" "ha-dummy_service" {
  manifest = {
    apiVersion = "v1"
    kind       = "Service"
    metadata = {
      name      = "ha-dummy"
      namespace = kubernetes_namespace.ha-dummy.metadata[0].name
    }
    spec = {
      ports = [
        {
          port        = 8123
          target_port = 8123
        }
      ]
      clusterIP = "None" # Headless service
    }
  }
  depends_on = [kubernetes_namespace.ha-dummy]
}

resource "kubernetes_manifest" "ha-dummy_ingressroute" {
  manifest = {
    apiVersion = "traefik.io/v1alpha1"
    kind       = "IngressRoute"
    metadata = {
      name      = "ha-dummy-ingressroute"
      namespace = kubernetes_namespace.ha-dummy.metadata[0].name
    }
    spec = {
      entryPoints = ["websecure"]
      routes = [
        {
          match = "Host(`ha.andywebservices.com`)"
          kind  = "Rule"
          services = [
            {
              name = "ha-dummy"
              port = 8123
            }
          ]
        }
      ]
      tls = {
        secretName = kubernetes_manifest.ha-dummy_certificate.manifest.spec.secretName
      }
    }
  }
}

resource "kubernetes_manifest" "ha-dummy_endpoints" {
  manifest = {
    apiVersion = "v1"
    kind       = "Endpoints"
    metadata = {
      name      = "ha-dummy"
      namespace = kubernetes_namespace.ha-dummy.metadata[0].name
    }
    subsets = [
      {
        addresses = [
          {
            ip = "192.168.0.130"
          }
        ]
        ports = [
          {
            port = "8123"
          }
        ]
      }
    ]
  }
}
