locals {
  general_prefix = format("%s-%s-%s", var.master_prefix, var.env_prefix, var.app_prefix)
}
