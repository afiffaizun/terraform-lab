output "container_name" {
  value       = docker_container.nginx.name
  description = "Nama container nginx"
}

output "nginx_url" {
  value       = "http://localhost:${var.external_port}"
  description = "URL akses nginx"
}

output "environment" {
  value       = var.environment
  description = "Environment aktif"
}

output "labels" {
  value       = local.common_labels
  description = "Label yang dipasang"
}

output "redis_enabled" {
  value       = var.enable_redis
  description = "Apakah redis aktif?"
}

output "redis_url" {
  value       = var.enable_redis ? "redis://:${var.redis_password}@localhost:${var.external_port + 1000}" : null
  description = "URL redis (kalau aktif)"
  sensitive   = true
}

output "extra_containers" {
  value       = [for c in docker_container.extra : c.name]
  description = "Daftar extra container"
}
