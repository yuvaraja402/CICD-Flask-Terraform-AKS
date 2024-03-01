terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=2.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "RG" {
  name     = "flask-terraform-deployment"
  location = "southindia"
}

resource "azurerm_kubernetes_cluster" "AKS" {
  name                = "CICD-TF-AKS"
  location            = azurerm_resource_group.RG.location
  resource_group_name = azurerm_resource_group.RG.name

  dns_prefix = "cicd-tf-aks"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_F2s_v2" # Use F2s v2 instance type
  }

  service_principal {
    client_id     = var.client_id
    client_secret = var.client_secret
  }

  tags = {
    Environment = "Production"
  }
}


# recieve all outputs of creation above
# AKS name, version, pods running

output "aks_name" {
  value = azurerm_kubernetes_cluster.AKS.name
}

output "aks_kubernetes_version" {
  value = azurerm_kubernetes_cluster.AKS.kubernetes_version
}
data "azurerm_kubernetes_cluster" "AKS" {
  name                = azurerm_kubernetes_cluster.AKS.name
  resource_group_name = azurerm_kubernetes_cluster.AKS.resource_group_name
}

resource "null_resource" "fetch_pods" {
  provisioner "local-exec" {
    command = <<-EOF
      kubectl get pods --all-namespaces --field-selector=status.phase=Running --output=json | jq '.items | length'
    EOF

    interpreter = ["bash", "-c"]
  }
}
output "number_of_pods" {
  value = null_resource.fetch_pods.triggers
}
