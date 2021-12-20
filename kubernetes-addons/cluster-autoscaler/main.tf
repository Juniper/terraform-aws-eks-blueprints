/*
 * Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
 * SPDX-License-Identifier: MIT-0
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this
 * software and associated documentation files (the "Software"), to deal in the Software
 * without restriction, including without limitation the rights to use, copy, modify,
 * merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
 * INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
 * PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 * OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
 * SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

resource "helm_release" "cluster_autoscaler" {
  count                      = var.manage_via_gitops ? 0 : 1
  name                       = local.helm_provider_config["name"]
  repository                 = local.helm_provider_config["repository"]
  chart                      = local.helm_provider_config["chart"]
  version                    = local.helm_provider_config["version"]
  namespace                  = local.helm_provider_config["namespace"]
  timeout                    = local.helm_provider_config["timeout"]
  values                     = local.helm_provider_config["values"]
  create_namespace           = local.helm_provider_config["create_namespace"]
  lint                       = local.helm_provider_config["lint"]
  description                = local.helm_provider_config["description"]
  repository_key_file        = local.helm_provider_config["repository_key_file"]
  repository_cert_file       = local.helm_provider_config["repository_cert_file"]
  repository_ca_file         = local.helm_provider_config["repository_ca_file"]
  repository_username        = local.helm_provider_config["repository_username"]
  repository_password        = local.helm_provider_config["repository_password"]
  verify                     = local.helm_provider_config["verify"]
  keyring                    = local.helm_provider_config["keyring"]
  disable_webhooks           = local.helm_provider_config["disable_webhooks"]
  reuse_values               = local.helm_provider_config["reuse_values"]
  reset_values               = local.helm_provider_config["reset_values"]
  force_update               = local.helm_provider_config["force_update"]
  recreate_pods              = local.helm_provider_config["recreate_pods"]
  cleanup_on_fail            = local.helm_provider_config["cleanup_on_fail"]
  max_history                = local.helm_provider_config["max_history"]
  atomic                     = local.helm_provider_config["atomic"]
  skip_crds                  = local.helm_provider_config["skip_crds"]
  render_subchart_notes      = local.helm_provider_config["render_subchart_notes"]
  disable_openapi_validation = local.helm_provider_config["disable_openapi_validation"]
  wait                       = local.helm_provider_config["wait"]
  wait_for_jobs              = local.helm_provider_config["wait_for_jobs"]
  dependency_update          = local.helm_provider_config["dependency_update"]
  replace                    = local.helm_provider_config["replace"]

  postrender {
    binary_path = local.helm_provider_config["postrender"]
  }

  dynamic "set" {
    iterator = each_item
    for_each = local.helm_provider_config["set"] == null ? [] : local.helm_provider_config["set"]

    content {
      name  = each_item.value.name
      value = each_item.value.value
    }
  }

  dynamic "set_sensitive" {
    iterator = each_item
    for_each = local.helm_provider_config["set_sensitive"] == null ? [] : local.helm_provider_config["set_sensitive"]

    content {
      name  = each_item.value.name
      value = each_item.value.value
    }
  }
}