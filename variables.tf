variable "location" {
  type        = string
  description = "Azure region"
  default     = "eastus"
}

variable "resource_group_name" {
  type        = string
  description = "Resource group name"
  default     = "aks-rg"
}

variable "vnet_name" {
  type        = string
  description = "VNet name"
  default     = "aks-vnet"
}

variable "vnet_cidr" {
  type        = string
  description = "VNet CIDR range"
  default     = "10.244.0.0/12"
}

variable "aks_subnet_name" {
  type        = string
  default     = "aks-subnet"
}

variable "aks_subnet_cidr" {
  type        = string
  default     = "10.244.0.0/16"
}

variable "appgw_subnet_name" {
  type        = string
  default     = "appgw-subnet"
}

variable "appgw_subnet_cidr" {
  type        = string
  description = "App Gateway subnet CIDR"
  default     = "10.225.0.0/16"
}

variable "aks_name" {
  type        = string
  description = "AKS cluster name"
  default     = "aks-cluster"
}

variable "dns_prefix" {
  type        = string
  description = "AKS DNS prefix"
  default     = "akscluster"
}

variable "node_vm_size" {
  type        = string
  default     = "Standard_DS2_v2"
}

variable "node_count" {
  type        = number
  default     = 1
}

variable "autoscaler_min_count" {
  type        = number
  default     = 1
}

variable "autoscaler_max_count" {
  type        = number
  default     = 2
}

variable "admin_username" {
  type        = string
  default     = "azureuser"
}
