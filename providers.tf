terraform {
  required_providers {
    shell = {
      source  = "scottwinkler/shell"
      version = "~>1.7.10"
    }
  }

  required_version = ">= 1.0.0"
}

provider "shell" {
  # interpreter = ["/bin/bash"]
  sensitive_environment = {
    AZURE_DEVOPS_EXT_PAT = var.ado_ext_pat
  }
}
