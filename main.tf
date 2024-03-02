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

# Execute commands after AKS creation
resource "null_resource" "aks_commands" {
  depends_on = [azurerm_kubernetes_cluster.AKS]

  provisioner "local-exec" {
    command = <<-EOT
      kubectl create namespace production
      kubectl -n production create deployment hello-flaskapp --image=cyberprince/flaskverapp:latest --port=5050
      kubectl -n production expose deployment hello-flaskapp --type=LoadBalancer --port=5050 --target-port=5050
      kubectl -n production get deployments
      kubectl -n production get services
      kubectl get nodes -o wide
    EOT
  }
}

# Output AKS details
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