terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

provider "docker" {}

resource "docker_image" "nginx" {
  name         = "nginx:alpine"
  keep_locally = true
}

# ─── Network ─────────────────────────────────────────
resource "docker_network" "lab" {
  name = "lab-net"
}

# ─── Redis ───────────────────────────────────────────
resource "docker_image" "redis" {
  name         = "redis:alpine"
  keep_locally = true
}

resource "docker_container" "redis" {
  name  = "lab-redis"
  image = docker_image.redis.image_id

  networks_advanced {
    name = docker_network.lab.name
  }

  ports {
    internal = 6379
    external = 6379
  }
}

resource "docker_container" "nginx" {
  name  = "lab-nginx"
  image = docker_image.nginx.image_id

  networks_advanced {
    name = docker_network.lab.name
  }

  ports {
    internal = 80
    external = 8080
  }

  env = [
    "REDIS_HOST=lab-redis",
    "REDIS_PORT=6379",
  ]

  depends_on = [docker_container.redis]
}

output "url" {
  value = "http://localhost:8080"
}

output "redis_host" {
  value       = "localhost:6379"
  description = "Redis dari host"
}

output "network_name" {
  value = docker_network.lab.name
}
