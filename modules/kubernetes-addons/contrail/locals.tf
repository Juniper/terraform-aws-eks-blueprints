locals {
  default_helm_config = {
    name             = "contrail"
    chart            = "aws-cn2"
    repository       = "https://juniper.github.io/cn2-helm/"
    version          = "1.2.0"
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
