terraform {
  required_providers {
    shell = {
      source  = "scottwinkler/shell"
      version = "~>1.7.10"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.1.0"
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

provider "azurerm" {
  features {}
}
