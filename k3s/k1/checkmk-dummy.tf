resource "kubernetes_namespace" "checkmk_dummy" {
  metadata {
    name = "checkmk-dummy"
  }
  depends_on = [kubernetes_manifest.cloudflare_clusterissuer]
}

resource "kubernetes_manifest" "checkmk_dummy_certificate" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name      = "checkmk-dummy-ingressroute-certificate"
      namespace = kubernetes_namespace.checkmk_dummy.metadata[0].name
    }
    spec = {
      secretName = "checkmk-dummy-certificate-secret"
      issuerRef = {
        name = kubernetes_manifest.cloudflare_clusterissuer.manifest.metadata.name
        kind = "ClusterIssuer"
      }
      dnsNames = [
        "checkmk.andywebservices.com"
      ]
    }
  }
  depends_on = [kubernetes_namespace.checkmk_dummy]
}

resource "kubernetes_manifest" "checkmk_dummy_service" {
  manifest = {
    apiVersion = "v1"
    kind       = "Service"
    metadata = {
      name      = "checkmk"
      namespace = kubernetes_namespace.checkmk_dummy.metadata[0].name
    }
    spec = {
      ports = [
        {
          port        = 8080
          target_port = 8080
        }
      ]
      clusterIP = "None" # Headless service
    }
  }
  depends_on = [kubernetes_namespace.checkmk_dummy]
}

resource "kubernetes_manifest" "checkmk_dummy_ingressroute" {
  manifest = {
    apiVersion = "traefik.io/v1alpha1"
    kind       = "IngressRoute"
    metadata = {
      name      = "checkmk-dummy-ingressroute"
      namespace = kubernetes_namespace.checkmk_dummy.metadata[0].name
    }
    spec = {
      entryPoints = ["websecure"]
      routes = [
        {
          match = "Host(`checkmk.andywebservices.com`)"
          kind  = "Rule"
          services = [
            {
              name = "checkmk"
              port = 8080
            }
          ]
        }
      ]
      tls = {
        secretName = kubernetes_manifest.checkmk_dummy_certificate.manifest.spec.secretName
      }
    }
  }
}

resource "kubernetes_manifest" "checkmk_dummy_endpoints" {
  manifest = {
    apiVersion = "v1"
    kind       = "Endpoints"
    metadata = {
      name      = "checkmk"
      namespace = kubernetes_namespace.checkmk_dummy.metadata[0].name
    }
    subsets = [
      {
        addresses = [
          {
            ip = "192.168.0.44"
          }
        ]
        ports = [
          {
            port = "8080"
          }
        ]
      }
    ]
  }
}
