variable "project_id" {
  description = "Google ID for the project"
  type        = string
  default     = "private-vectordb"
}

variable "location" {
  description = "Location for the project and cluster"
  type        = string
  default     = "us-central1"
}

variable "network" {
  description = "Name of the network to deploy the cluster into"
  type        = string
  default     = "default"
}

variable "subnet" {
  description = "Name of the subnet to deploy the cluster into"
  type        = string
  default     = "default"
}

variable "name" {
  description = "Name for the cluster"
  type        = string
  default     = "private-vectordb"
}

variable "primary_ip_range" {
  description = "The range of the IPs for the VPC and cluster"
  type        = string
  default     = "10.0.0.0/16"
}

variable "service_ip_range" {
  description = "The range of the IPs for services within the cluster"
  type        = string
  default     = "10.1.0.0/16"
}

variable "pod_ip_range" {
  description = "The range of the IPs for pods within the cluster"
  type        = string
  default     = "10.2.0.0/16"
}
