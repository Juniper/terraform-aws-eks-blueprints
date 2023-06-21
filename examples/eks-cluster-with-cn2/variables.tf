# tflint-ignore: terraform_unused_declarations

variable "name" {
  description = "Name of cluster - used by Terratest for e2e test automation"
  type        = string
  default     = "cn2cluster"
}

variable "region" {
  default = "us-east-1"
}
variable "vpc_cidr" {
  default = "10.0.0.0/16"
}
variable "repository"{
 default = "https://juniper.github.io/cn2-helm/"
}
variable "chart_version"{
 default = "23.1.1"
}

variable "container_pull_secret" {
}
