locals {
  # Nama lengkap dengan environment prefix
  full_name = "${var.container_name}-${var.environment}"

  # Label standar
  common_labels = merge(var.tags, {
    environment = var.environment
    managed_by  = "terraform"
  })

  # Port redis internal (fixed)
  redis_internal_port = 6379

  # Apakah environment ini production?
  is_prod = var.environment == "prod"

  # Konversi list ke map (untuk for_each)
  extra_map = {
    for c in var.extra_containers : c.name => c
  }
}
