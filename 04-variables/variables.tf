variable "container_name" {
  type        = string
  description = "Nama container nginx"

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,30}$", var.container_name))
    error_message = "container_name harus diawali huruf kecil, hanya boleh huruf kecil, angka, dan '-', panjang 2-31 karakter."
  }
}

variable "external_port" {
  type        = number
  description = "Port Host yang di map ke container"
  default     = 8080

  validation {
    condition     = var.external_port > 1024 && var.external_port < 65535
    error_message = "Port harus di antara 1025 dan 65534."
  }
}

variable "environment" {
  type        = string
  description = "Environment: dev, staging, atau prod"
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment harus salah satu dari: dev, staging, atau prod."
  }
}

variable "tags" {
  type        = map(string)
  description = "Tags untuk labeling container"
  default = {
    owner   = "student"
    project = "terraform-lab"
  }
}

variable "enable_redis" {
  type        = bool
  description = "Apakah redis aktif?"
  default     = false
}

variable "redis_password" {
  type        = string
  description = "Password sensitive"
  default     = "changeme"
  sensitive   = true
}

variable "extra_containers" {
  type = list(object({
    name  = string
    image = string
    port  = number
  }))
  description = "Container tambahan"
  default     = []
}
