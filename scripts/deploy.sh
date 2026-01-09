 #!/bin/bash
# deploy.sh - Complete deployment script

set -e  # Exit on error

echo "🚀 Starting CI/CD Deployment Pipeline"
echo "======================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored messages
print_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

print_info() {
    echo -e "${YELLOW}[i]${NC} $1"
}

# Check prerequisites
print_info "Checking prerequisites..."

check_command() {
    if command -v $1 &> /dev/null; then
        print_success "$1 is installed"
        return 0
    else
        print_error "$1 is not installed"
        return 1
    fi
}

check_command "docker"
check_command "docker-compose"
check_command "curl"

# Build images
print_info "Building Docker images..."
docker-compose build --no-cache

# Run tests
print_info "Running tests..."
docker-compose -f docker-compose.test.yml up --abort-on-container-exit

# Security scan
print_info "Running security scans..."
if command -v trivy &> /dev/null; then
    trivy image php-microservices-api:latest
    trivy image php-microservices-frontend:latest
else
    docker scan php-microservices-api:latest
    docker scan php-microservices-frontend:latest
fi

# Deploy
print_info "Deploying services..."
docker-compose down 2>/dev/null || true
docker-compose up -d

# Wait and verify
print_info "Waiting for services to start..."
sleep 30

print_info "Running health checks..."
curl -f http://localhost:9000/api/health.php || {
    print_error "Health check failed"
    docker-compose logs api
    exit 1
}

print_success "Deployment successful!"
print_info "Services:"
print_info "  Frontend: http://localhost:9000"
print_info "  API: http://localhost:9000/api/"
print_info "  Load Balancer: http://localhost:9001"

# Performance test
print_info "Running quick performance test..."
if command -v ab &> /dev/null; then
    ab -n 100 -c 10 http://localhost:9000/api/health.php
fi

echo ""
print_success "🎉 CI/CD Pipeline Complete!"
