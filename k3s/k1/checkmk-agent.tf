resource "kubernetes_namespace" "checkmk_agent" {
  metadata {
    name = "checkmk-agent"
  }
}

resource "helm_release" "checkmk_agent" {
  name       = "checkmk-agent-chart"
  namespace  = kubernetes_namespace.checkmk_agent.metadata[0].name
  chart      = "checkmk"
  repository = "https://checkmk.github.io/checkmk_kube_agent"
  values = [file("./config/checkmk-agent/helm-values.yaml")]
}

