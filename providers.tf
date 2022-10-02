terraform {
  required_providers {
    shell = {
      source  = "scottwinkler/shell"
      version = "~>1.7.10"
    }
  }

  required_version = ">= 0.13.0"
}

provider "shell" {
  sensitive_environment = {
    AZURE_DEVOPS_EXT_PAT = var.ado_ext_pat
  }
}
