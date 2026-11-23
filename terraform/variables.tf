variable "region" {
  description = "Cloud region for VM deployment"
  type        = string
  default     = "eu-west-1"
}

variable "instance_type" {
  description = "VM size for the Minecraft Game Host"
  type        = string
  default     = "t3.medium"
}

variable "ssh_public_key" {
  description = "SSH public key for Ansible access"
  type        = string
}