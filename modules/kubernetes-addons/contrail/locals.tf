locals {
  default_helm_config = {
    name             = "contrail"
    chart            = "cn2-eks"
    repository       = "https://juniper.github.io/cn2-helm/"
    version          = "0.2.1"
    namespace        = "default"
    create_namespace = false
    description      = "cn2 helm Chart deployment configuration"
  }

  helm_config = merge(
    local.default_helm_config,
    var.helm_config
  )

  default_helm_values = [templatefile("${path.module}/values.yaml", {})]

  argocd_gitops_config = {
    enable = true
  }
}
