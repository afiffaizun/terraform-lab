terraform {
  required_version = ">= 1.5.0"
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

provider "docker" {}

# ─── Network ─────────────────────────────────────────
resource "docker_network" "lab" {
  name = "lab-net-${var.environment}"
}

# ─── Images ──────────────────────────────────────────
resource "docker_image" "nginx" {
  name         = "nginx:alpine"
  keep_locally = true
}

resource "docker_image" "redis" {
  count        = var.enable_redis ? 1 : 0
  name         = "redis:alpine"
  keep_locally = true
}

resource "docker_image" "extra" {
  for_each     = local.extra_map
  name         = each.value.image
  keep_locally = true
}

# ─── Nginx (utama) ───────────────────────────────────
resource "docker_container" "nginx" {
  name  = local.full_name
  image = docker_image.nginx.image_id

  networks_advanced {
    name = docker_network.lab.name
  }

  ports {
    internal = 80
    external = var.external_port
  }

  env = [
    "ENVIRONMENT=${var.environment}",
  ]

  restart = local.is_prod ? "always" : "no"

  dynamic "labels" {
    for_each = local.common_labels
    content {
      label = labels.key
      value = labels.value
    }
  }
}

# ─── Redis (opsional) ─────────────────────────────────
resource "docker_container" "redis" {
  count = var.enable_redis ? 1 : 0

  name  = "${local.full_name}-redis"
  image = docker_image.redis[0].image_id

  networks_advanced {
    name = docker_network.lab.name
  }

  ports {
    internal = local.redis_internal_port
    external = var.external_port + 1000
  }

  # Pakai password dari variabel agar var.redis_password terpakai
  command = [
    "redis-server",
    "--requirepass",
    var.redis_password,
  ]
}

# ─── Extra containers (for_each dari var.extra_containers) ──
resource "docker_container" "extra" {
  for_each = local.extra_map

  name  = each.value.name
  image = docker_image.extra[each.key].image_id

  networks_advanced {
    name = docker_network.lab.name
  }

  ports {
    internal = 80
    external = each.value.port
  }

  dynamic "labels" {
    for_each = local.common_labels
    content {
      label = labels.key
      value = labels.value
    }
  }
}
