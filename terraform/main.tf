terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.20"
    }
  }
}

# Docker Provider
provider "docker" {
  host = "unix:///var/run/docker.sock"
}

# Create Docker network
resource "docker_network" "microservices_network" {
  name = "microservices_network"
  driver = "bridge"
}

# Create MySQL container
resource "docker_container" "mysql" {
  name  = "mysql"
  image = "mysql:8.4"
  restart = "always"
  
  env = [
    "MYSQL_ROOT_PASSWORD=${var.db_root_password}",
    "MYSQL_DATABASE=microservices_db",
    "MYSQL_USER=app_user",
    "MYSQL_PASSWORD=${var.db_password}"
  ]
  
  volumes {
    host_path      = "/opt/mysql/data"
    container_path = "/var/lib/mysql"
  }
  
  networks_advanced {
    name = docker_network.microservices_network.name
  }
  
  healthcheck {
    test     = ["CMD", "mysqladmin", "ping", "-h", "localhost"]
    interval = "10s"
    timeout  = "5s"
    retries  = 3
  }
}

# Create API container
resource "docker_container" "api" {
  name  = "api"
  image = "ghcr.io/${var.github_username}/php-microservices-api:${var.image_tag}"
  restart = "always"
  
  depends_on = [docker_container.mysql]
  
  env = [
    "DB_HOST=mysql",
    "DB_NAME=microservices_db",
    "DB_USER=app_user",
    "DB_PASSWORD=${var.db_password}"
  ]
  
  networks_advanced {
    name = docker_network.microservices_network.name
  }
  
  ports {
    internal = 80
    external = 9001
  }
}

# Create Frontend container
resource "docker_container" "frontend" {
  name  = "frontend"
  image = "ghcr.io/${var.github_username}/php-microservices-frontend:${var.image_tag}"
  restart = "always"
  
  depends_on = [docker_container.api]
  
  networks_advanced {
    name = docker_network.microservices_network.name
  }
  
  ports {
    internal = 80
    external = 9000
  }
}

# Variables
variable "db_root_password" {
  type      = string
  sensitive = true
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "github_username" {
  type = string
}

variable "image_tag" {
  type    = string
  default = "latest"
}
