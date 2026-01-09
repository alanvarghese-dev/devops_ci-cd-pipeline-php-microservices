#!/bin/bash
# monitor.sh - Real-time monitoring

echo "📊 PHP Microservices Monitoring Dashboard"
echo "========================================"

while true; do
    clear
    
    # Service Status
    echo "Service Status:"
    echo "---------------"
    for service in api frontend mysql loadbalancer; do
        if docker-compose ps $service | grep -q "Up"; then
            echo "✅ $service: RUNNING"
        else
            echo "❌ $service: STOPPED"
        fi
    done
    
    echo ""
    
    # API Health
    echo "API Health Check:"
    echo "----------------"
    RESPONSE=$(curl -s http://localhost:9000/api/health.php | jq -r '.status' 2>/dev/null || echo "ERROR")
    echo "Status: $RESPONSE"
    
    echo ""
    
    # Resource Usage
    echo "Resource Usage:"
    echo "--------------"
    docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}" | grep microservices
    
    echo ""
    
    # Recent Logs
    echo "Recent Errors (last 5 minutes):"
    echo "------------------------------"
    docker-compose logs --since=5m 2>/dev/null | grep -i "error\|exception\|failed" | tail -5 || echo "No recent errors"
    
    echo ""
    echo "Press Ctrl+C to exit. Refreshing in 10 seconds..."
    sleep 10
done
