variable "ssh-key" {
  type        = string
  default     = ""
  description = "SSH Key to access bastion server"
}

variable "ssh-user" {
  type        = string
  description = "SSH user for compute instance"
  default     = "myusername"
  sensitive   = false
}

variable "host-check" {
  type        = string
  description = "Dont add private key to known_hosts"
  default     = "-o StrictHostKeyChecking=no"
  sensitive   = false
}

variable "ignore-known-hosts" {
  type        = string
  description = "Ignore (many) keys stored in the ssh-agent; use explicitly declared keys"
  default     = "-o IdentitiesOnly=yes"
  sensitive   = false
}
