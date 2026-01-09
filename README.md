🚀 PHP Microservices CI/CD Pipeline Project

📋 Project Overview

A production-ready PHP microservices architecture with a complete CI/CD pipeline, monitoring stack, and containerized services. This project demonstrates modern DevOps practices for deploying and managing PHP applications in a microservices environment.

🏗️ Architecture Diagram

┌─────────────────────────────────────────────────────────────────────┐
│                        Microservices Architecture                    │
├─────────────────────────────────────────────────────────────────────┤
│  Client → Load Balancer (Nginx) → API Gateway → Microservices       │
│                                                                     │
│  Microservices:                                                     │
│    • User Service (PHP)        • Order Service (PHP)               │
│    • Product Service (PHP)     • Payment Service (PHP)             │
│                                                                     │
│  Supporting Services:                                               │
│    • MySQL Database           • Redis Cache                        │
│    • Monitoring Stack         • CI/CD Pipeline                     │
└─────────────────────────────────────────────────────────────────────┘


⚡ Quick Start

Prerequisites

# Verify Docker and Docker Compose are installed
docker --version
docker-compose --version

# Required versions
# Docker: 20.10+
# Docker Compose: 2.0+

One-Command Deployment

# Clone the repository
git clone <your-repository-url>
cd php-microservices

# Start all services
docker-compose up -d --build

# Verify deployment
docker-compose ps

🛠️ Service Configuration & Port Mapping

Service	Port	Purpose	Access URL	Status
Main Application	9000	Primary PHP Application	http://localhost:9000	✅ Operational
Monitoring Dashboard	9001	Service Monitoring & Metrics	http://localhost:9001	✅ Operational
API Gateway	8081	API Gateway & Management	http://localhost:8081	✅ Operational
Development UI	3000	Frontend Development Server	http://localhost:3000	✅ Operational
Metrics Collector	9090	System Metrics & Analytics	http://localhost:9090	✅ Operational


Note: All networking issues have been resolved without changing the original port configuration.

📁 Project Structure


php-microservices/
├── docker-compose.yml          # Main orchestration file
├── .env.example                # Environment variables template
├── README.md                   # This file
├── src/                        # PHP application source code
│   ├── user-service/           # User management microservice
│   ├── product-service/        # Product catalog microservice
│   ├── order-service/          # Order processing microservice
│   └── shared/                 # Shared libraries and utilities
├── nginx/                      # Nginx configuration
│   ├── nginx.conf
│   └── sites-available/
├── mysql/                      # Database configuration
│   └── init.sql
├── scripts/                    # Utility scripts
│   ├── deploy.sh
│   ├── backup.sh
│   └── health-check.sh
└── monitoring/                 # Monitoring configuration
    ├── prometheus/
    └── grafana/


🔧 Detailed Setup Instructions

1. Environment Configuration

# Copy environment template
cp .env.example .env

# Edit environment variables
nano .env

# Set required variables
APP_NAME="PHP Microservices"
APP_ENV=production
DB_HOST=mysql
DB_PORT=3306
DB_DATABASE=microservices
DB_USERNAME=admin
DB_PASSWORD=your_secure_password

2. Build and Deploy


# Option 1: Full deployment (builds images)
docker-compose up -d --build

# Option 2: Start existing containers
docker-compose up -d

# Option 3: Force rebuild specific service
docker-compose up -d --build api-service

3. Verify Deployment

# Check all containers are running
docker-compose ps

# View real-time logs
docker-compose logs -f

# Check service health
curl http://localhost:9000/health
curl http://localhost:9001/health

🐳 Docker Compose Configuration

Main Services

version: '3.8'
services:
  # PHP Application Service (Port 9000)
  php-app:
    build:
      context: ./src
      dockerfile: Dockerfile.php
    container_name: php-microservice-app
    ports:
      - "9000:9000"
    volumes:
      - ./src:/var/www/html
      - ./php/php.ini:/usr/local/etc/php/php.ini
    environment:
      - APP_ENV=${APP_ENV}
      - DB_HOST=${DB_HOST}
    networks:
      - app-network
    depends_on:
      - mysql
      - redis

  # API Gateway (Port 8081)
  api-gateway:
    image: nginx:alpine
    container_name: api-gateway
    ports:
      - "8081:80"
    volumes:
      - ./nginx/api-gateway.conf:/etc/nginx/nginx.conf
      - ./src:/var/www/html
    networks:
      - app-network
    depends_on:
      - php-app

  # Monitoring Dashboard (Port 9001)
  monitoring:
    image: grafana/grafana:latest
    container_name: monitoring-dashboard
    ports:
      - "9001:3000"
    volumes:
      - ./monitoring/grafana:/var/lib/grafana
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=${GRAFANA_PASSWORD}
    networks:
      - app-network

  # Development Frontend (Port 3000)
  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile.node
    container_name: frontend-dev
    ports:
      - "3000:3000"
    volumes:
      - ./frontend:/app
      - /app/node_modules
    networks:
      - app-network

  # Metrics Collector (Port 9090)
  prometheus:
    image: prom/prometheus:latest
    container_name: prometheus
    ports:
      - "9090:9090"
    volumes:
      - ./monitoring/prometheus.yml:/etc/prometheus/prometheus.yml
      - prometheus_data:/prometheus
    networks:
      - app-network

  # Database
  mysql:
    image: mysql:8.0
    container_name: mysql-db
    environment:
      MYSQL_ROOT_PASSWORD: ${DB_PASSWORD}
      MYSQL_DATABASE: ${DB_DATABASE}
    volumes:
      - mysql_data:/var/lib/mysql
      - ./mysql/init.sql:/docker-entrypoint-initdb.d/init.sql
    networks:
      - app-network

  # Cache
  redis:
    image: redis:alpine
    container_name: redis-cache
    networks:
      - app-network

networks:
  app-network:
    driver: bridge

volumes:
  mysql_data:
  prometheus_data:

🔍 Health Checks & Monitoring

Service Health Endpoints

# Application health
curl http://localhost:9000/health

# API Gateway status
curl http://localhost:8081/status

# Database connectivity
docker-compose exec mysql mysqladmin ping -h localhost

# Redis connectivity
docker-compose exec redis redis-cli ping

Monitoring Script

Create scripts/health-check.sh:

#!/bin/bash

echo "🔍 Running Microservices Health Check..."
echo "========================================="

services=(
  "PHP Application:9000"
  "Monitoring Dashboard:9001"
  "API Gateway:8081"
  "Development Frontend:3000"
  "Metrics Collector:9090"
)

for service in "${services[@]}"; do
  name="${service%:*}"
  port="${service#*:}"
  
  if curl -s -f "http://localhost:$port" > /dev/null; then
    echo "✅ $name (port $port): UP"
  else
    echo "❌ $name (port $port): DOWN"
  fi
done

echo "========================================="

📊 Useful Commands

Development

# Start development environment
docker-compose up -d

# Stop all services
docker-compose down

# Rebuild specific service
docker-compose up -d --build php-app

# View logs for specific service
docker-compose logs -f php-app

# Execute command inside container
docker-compose exec php-app composer install
docker-compose exec mysql mysql -u root -p

Database Operations

# Backup database
docker-compose exec mysql mysqldump -u root -p${DB_PASSWORD} ${DB_DATABASE} > backup.sql

# Restore database
docker-compose exec -i mysql mysql -u root -p${DB_PASSWORD} ${DB_DATABASE} < backup.sql

# Run migrations
docker-compose exec php-app php artisan migrate

Maintenance

# Check resource usage
docker stats

# List all containers
docker ps -a

# Clean up unused resources
docker system prune -a

# Update all images
docker-compose pull

🚀 Deployment to Production

1. Production Environment Variables

# Create production environment file
cp .env.production.example .env.production

# Set production values
APP_ENV=production
APP_DEBUG=false
APP_URL=https://yourdomain.com

# Security
APP_KEY=generate_secure_key_here
DB_PASSWORD=strong_production_password

2. Production Deployment

# Deploy with production configuration
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d --build

# Enable SSL (using Let's Encrypt)
./scripts/setup-ssl.sh yourdomain.com

3. Scaling Services


# Scale PHP application instances
docker-compose up -d --scale php-app=3

# Load balancer configuration
# See nginx/load-balancer.conf for example configuration

🐛 Troubleshooting Guide

Common Issues

1. Port Already in Use

# Check what's using the port
sudo lsof -i :9000

# Kill process if necessary
sudo kill -9 <PID>

# Or change port in docker-compose.yml
# php-app:
#   ports:
#     - "9001:9000"  # Change host port

2. Docker Compose Build Errors

# Clear Docker cache
docker system prune -a

# Rebuild without cache
docker-compose build --no-cache

# Check Dockerfile syntax
docker build -t test-image .

3. Database Connection Issues

# Check if MySQL is running
docker-compose ps mysql

# View MySQL logs
docker-compose logs mysql

# Test connection from PHP container
docker-compose exec php-app php -r "new PDO('mysql:host=mysql;dbname=microservices', 'root', 'password');"

4. Permission Issues

# Fix file permissions
sudo chown -R $USER:$USER .
sudo chmod -R 755 storage bootstrap/cache

# Docker volume permissions
docker-compose exec php-app chown -R www-data:www-data /var/www/html/storage

Debug Mode

# Run with debug output
docker-compose up --verbose

# Check container logs
docker logs <container_id> --tail 50 -f

# Inspect container
docker inspect <container_id>

📈 Monitoring & Logging

View Logs

# All services logs
docker-compose logs

# Follow specific service logs
docker-compose logs -f php-app

# Check error logs
docker-compose exec php-app tail -f /var/log/php/error.log

Performance Monitoring

# Check container resource usage
docker stats

# Monitor application performance
curl http://localhost:9000/debug/performance

# Database performance
docker-compose exec mysql mysqladmin status

🔒 Security Best Practices

1. Update Default Credentials

# Change all default passwords
./scripts/change-passwords.sh

# Generate secure keys
php artisan key:generate

2. Network Security

# Restrict network exposure
services:
  mysql:
    networks:
      - internal-network

# Use internal networks for sensitive services
networks:
  internal-network:
    internal: true

3. Regular Updates

# Update all images
docker-compose pull

# Scan for vulnerabilities
docker scan php-app

🤝 Contributing

Development Workflow

Fork the repository
Create a feature branch
Make changes
Test with docker-compose up -d --build
Submit pull request

Coding Standards

# Run PHP Code Sniffer
docker-compose exec php-app ./vendor/bin/phpcs

# Run tests
docker-compose exec php-app php artisan test

📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

📊 Deployment Status

✅ Docker Compose configuration: Operational
✅ All services running on designated ports
✅ Networking issues: Resolved
✅ CI/CD Pipeline: Ready
🔄 Monitoring: Configured
🔄 Production deployment: Tested
Port Configuration: 9000, 9001, 8081, 3000, 9090

🚀 Quick Deployment Summary

# 1. Clone repository
git clone https://github.com/yourusername/php-microservices.git
cd php-microservices

# 2. Configure environment
cp .env.example .env
nano .env  # Edit with your configuration

# 3. Deploy
docker-compose up -d --build

# 4. Verify
./scripts/health-check.sh

# 5. Access services:
#    App:        http://localhost:9000
#    Monitoring: http://localhost:9001
#    API:        http://localhost:8081
#    Frontend:   http://localhost:3000
#    Metrics:    http://localhost:9090


