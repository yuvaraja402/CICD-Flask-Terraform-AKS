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
  name     = "CICD-terraform-deployment"
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
      sleep 120 # Wait for 1 minute to ensure AKS is fully initialized
      kubectl create namespace dev || true # Ignore error if namespace already exists
      sleep 10
      kubectl -n dev create deployment flaskapp --image=cyberprince/flaskverapp:v1 --port=5050
      sleep 30
      kubectl -n dev expose deployment flaskapp --type=LoadBalancer --port=5050 --target-port=5050
      sleep 60
      kubectl -n dev get deployments
      kubectl -n dev get services
      kubectl get nodes -o wide
    EOT
  }
}