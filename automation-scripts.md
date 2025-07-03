# DevOps Automation Scripts

## Deployment Scripts

### Blue-Green Deployment Script
```bash
#!/bin/bash

# blue-green-deploy.sh
set -e

ENVIRONMENT=${1:-staging}
IMAGE_TAG=${2:-latest}
APP_NAME="web-app"
NAMESPACE="production"

echo "Starting blue-green deployment for ${APP_NAME} with tag ${IMAGE_TAG}"

# Get current deployment
CURRENT_COLOR=$(kubectl get service ${APP_NAME} -n ${NAMESPACE} -o jsonpath='{.spec.selector.color}' 2>/dev/null || echo "blue")
NEW_COLOR=$([ "$CURRENT_COLOR" = "blue" ] && echo "green" || echo "blue")

echo "Current color: ${CURRENT_COLOR}, deploying to: ${NEW_COLOR}"

# Update deployment with new image
kubectl set image deployment/${APP_NAME}-${NEW_COLOR} \
    ${APP_NAME}=${APP_NAME}:${IMAGE_TAG} \
    -n ${NAMESPACE}

echo "Waiting for rollout to complete..."
kubectl rollout status deployment/${APP_NAME}-${NEW_COLOR} -n ${NAMESPACE} --timeout=600s

# Health check
echo "Performing health check..."
HEALTH_CHECK_URL="http://${APP_NAME}-${NEW_COLOR}.${NAMESPACE}.svc.cluster.local:8080/health"
for i in {1..30}; do
    if kubectl run health-check-${NEW_COLOR} --rm -i --restart=Never --image=curlimages/curl -- \
        curl -f ${HEALTH_CHECK_URL}; then
        echo "Health check passed"
        break
    fi
    echo "Health check failed, retrying in 10s..."
    sleep 10
done

# Switch traffic
echo "Switching traffic to ${NEW_COLOR}"
kubectl patch service ${APP_NAME} -n ${NAMESPACE} -p '{"spec":{"selector":{"color":"'${NEW_COLOR}'"}}}'

echo "Deployment completed successfully!"
echo "To rollback, run: kubectl patch service ${APP_NAME} -n ${NAMESPACE} -p '{\"spec\":{\"selector\":{\"color\":\"${CURRENT_COLOR}\"}}}'
```

### Rolling Update Deployment
```bash
#!/bin/bash

# rolling-update.sh
set -e

APP_NAME=${1}
IMAGE_TAG=${2}
NAMESPACE=${3:-default}

if [[ -z "$APP_NAME" || -z "$IMAGE_TAG" ]]; then
    echo "Usage: $0 <app-name> <image-tag> [namespace]"
    exit 1
fi

echo "Deploying ${APP_NAME}:${IMAGE_TAG} to namespace ${NAMESPACE}"

# Update deployment
kubectl set image deployment/${APP_NAME} ${APP_NAME}=${APP_NAME}:${IMAGE_TAG} -n ${NAMESPACE}

# Wait for rollout
kubectl rollout status deployment/${APP_NAME} -n ${NAMESPACE} --timeout=600s

# Verify deployment
READY_REPLICAS=$(kubectl get deployment ${APP_NAME} -n ${NAMESPACE} -o jsonpath='{.status.readyReplicas}')
DESIRED_REPLICAS=$(kubectl get deployment ${APP_NAME} -n ${NAMESPACE} -o jsonpath='{.spec.replicas}')

if [[ "$READY_REPLICAS" -eq "$DESIRED_REPLICAS" ]]; then
    echo "Deployment successful! ${READY_REPLICAS}/${DESIRED_REPLICAS} replicas ready"
else
    echo "Deployment failed! Only ${READY_REPLICAS}/${DESIRED_REPLICAS} replicas ready"
    exit 1
fi
```

## Monitoring Scripts

### Health Check Script
```bash
#!/bin/bash

# health-check.sh
SERVICES=(
    "http://app1.example.com/health"
    "http://app2.example.com/health"
    "http://database.example.com:5432"
)

WEBHOOK_URL="${SLACK_WEBHOOK_URL}"
TIMEOUT=10

send_alert() {
    local service=$1
    local status=$2
    local message="🚨 Service Alert: ${service} is ${status}"
    
    if [[ -n "$WEBHOOK_URL" ]]; then
        curl -X POST -H 'Content-type: application/json' \
            --data "{\"text\":\"${message}\"}" \
            "$WEBHOOK_URL"
    fi
    echo "${message}"
}

check_http_service() {
    local url=$1
    local status_code=$(curl -o /dev/null -s -w "%{http_code}" --max-time $TIMEOUT "$url")
    
    if [[ "$status_code" -eq 200 ]]; then
        echo "✅ ${url} - OK"
        return 0
    else
        echo "❌ ${url} - FAILED (HTTP ${status_code})"
        send_alert "$url" "DOWN"
        return 1
    fi
}

check_tcp_service() {
    local host_port=$1
    local host=$(echo $host_port | cut -d: -f1)
    local port=$(echo $host_port | cut -d: -f2)
    
    if timeout $TIMEOUT bash -c "</dev/tcp/$host/$port"; then
        echo "✅ ${host_port} - OK"
        return 0
    else
        echo "❌ ${host_port} - FAILED"
        send_alert "$host_port" "DOWN"
        return 1
    fi
}

main() {
    echo "Starting health checks at $(date)"
    local failed_services=0
    
    for service in "${SERVICES[@]}"; do
        if [[ "$service" =~ ^http ]]; then
            check_http_service "$service" || ((failed_services++))
        else
            check_tcp_service "$service" || ((failed_services++))
        fi
    done
    
    echo "Health check completed. Failed services: $failed_services"
    exit $failed_services
}

main "$@"
```

### Log Analysis Script
```bash
#!/bin/bash

# log-analyzer.sh
LOG_FILE=${1:-/var/log/application.log}
TIME_RANGE=${2:-"1 hour ago"}
THRESHOLD=${3:-100}

if [[ ! -f "$LOG_FILE" ]]; then
    echo "Error: Log file $LOG_FILE not found"
    exit 1
fi

echo "Analyzing logs from $(date -d "$TIME_RANGE") to now"
echo "Log file: $LOG_FILE"
echo "Error threshold: $THRESHOLD"
echo "================================"

# Get logs from specified time range
SINCE_TIMESTAMP=$(date -d "$TIME_RANGE" "+%Y-%m-%d %H:%M:%S")
RECENT_LOGS=$(awk -v since="$SINCE_TIMESTAMP" '$0 >= since' "$LOG_FILE")

# Count errors
ERROR_COUNT=$(echo "$RECENT_LOGS" | grep -i error | wc -l)
WARN_COUNT=$(echo "$RECENT_LOGS" | grep -i warn | wc -l)
TOTAL_REQUESTS=$(echo "$RECENT_LOGS" | grep -E "GET|POST|PUT|DELETE" | wc -l)

echo "Summary:"
echo "- Total requests: $TOTAL_REQUESTS"
echo "- Errors: $ERROR_COUNT"
echo "- Warnings: $WARN_COUNT"

if [[ $ERROR_COUNT -gt $THRESHOLD ]]; then
    echo "🚨 Alert: Error count ($ERROR_COUNT) exceeds threshold ($THRESHOLD)"
    
    echo -e "\nTop error patterns:"
    echo "$RECENT_LOGS" | grep -i error | \
        sed 's/[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\} [0-9]\{2\}:[0-9]\{2\}:[0-9]\{2\}//' | \
        sort | uniq -c | sort -nr | head -5
fi

# Response time analysis
echo -e "\nResponse time analysis:"
echo "$RECENT_LOGS" | grep -oE "response_time=[0-9.]+" | \
    cut -d= -f2 | \
    awk '{
        sum += $1
        count++
        if ($1 > max) max = $1
        if (min == "" || $1 < min) min = $1
    }
    END {
        if (count > 0) {
            print "- Average response time: " sum/count "ms"
            print "- Min response time: " min "ms"
            print "- Max response time: " max "ms"
        }
    }'
```

## Infrastructure Management Scripts

### Resource Cleanup Script
```bash
#!/bin/bash

# cleanup-resources.sh
set -e

DRY_RUN=${DRY_RUN:-false}
DAYS_OLD=${DAYS_OLD:-7}

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

cleanup_docker() {
    log "Cleaning up Docker resources..."
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log "DRY RUN: Would remove unused Docker resources"
        docker system df
        docker images --filter "dangling=true" --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"
    else
        log "Removing dangling images..."
        docker image prune -f
        
        log "Removing unused volumes..."
        docker volume prune -f
        
        log "Removing unused networks..."
        docker network prune -f
        
        log "Removing stopped containers older than ${DAYS_OLD} days..."
        docker container prune --filter "until=${DAYS_OLD}d" -f
    fi
}

cleanup_kubernetes() {
    log "Cleaning up Kubernetes resources..."
    
    # Clean up completed jobs
    COMPLETED_JOBS=$(kubectl get jobs --all-namespaces --field-selector status.successful=1 -o name 2>/dev/null || true)
    
    if [[ -n "$COMPLETED_JOBS" && "$DRY_RUN" != "true" ]]; then
        echo "$COMPLETED_JOBS" | xargs kubectl delete
        log "Removed completed jobs"
    elif [[ "$DRY_RUN" == "true" ]]; then
        log "DRY RUN: Would remove $(echo "$COMPLETED_JOBS" | wc -l) completed jobs"
    fi
    
    # Clean up evicted pods
    EVICTED_PODS=$(kubectl get pods --all-namespaces --field-selector status.phase=Failed -o name 2>/dev/null || true)
    
    if [[ -n "$EVICTED_PODS" && "$DRY_RUN" != "true" ]]; then
        echo "$EVICTED_PODS" | xargs kubectl delete
        log "Removed failed/evicted pods"
    elif [[ "$DRY_RUN" == "true" ]]; then
        log "DRY RUN: Would remove $(echo "$EVICTED_PODS" | wc -l) failed pods"
    fi
}

cleanup_logs() {
    log "Cleaning up old log files..."
    
    LOG_DIRS=(
        "/var/log"
        "/opt/app/logs"
        "/tmp"
    )
    
    for dir in "${LOG_DIRS[@]}"; do
        if [[ -d "$dir" ]]; then
            if [[ "$DRY_RUN" == "true" ]]; then
                find "$dir" -name "*.log" -type f -mtime +${DAYS_OLD} -ls
            else
                find "$dir" -name "*.log" -type f -mtime +${DAYS_OLD} -delete
                log "Cleaned logs in $dir older than ${DAYS_OLD} days"
            fi
        fi
    done
}

main() {
    log "Starting cleanup process (DRY_RUN=$DRY_RUN, DAYS_OLD=$DAYS_OLD)"
    
    if command -v docker &> /dev/null; then
        cleanup_docker
    fi
    
    if command -v kubectl &> /dev/null; then
        cleanup_kubernetes
    fi
    
    cleanup_logs
    
    log "Cleanup completed"
}

main "$@"
```

### SSL Certificate Checker
```bash
#!/bin/bash

# ssl-checker.sh
DOMAINS=(
    "example.com:443"
    "api.example.com:443"
    "app.example.com:443"
)

ALERT_DAYS=30
WEBHOOK_URL="${SLACK_WEBHOOK_URL}"

check_certificate() {
    local domain_port=$1
    local domain=$(echo $domain_port | cut -d: -f1)
    local port=$(echo $domain_port | cut -d: -f2)
    
    echo "Checking certificate for $domain:$port"
    
    # Get certificate expiry date
    local cert_date=$(echo | openssl s_client -servername $domain -connect $domain_port 2>/dev/null | \
        openssl x509 -noout -dates | grep notAfter | cut -d= -f2)
    
    if [[ -z "$cert_date" ]]; then
        echo "❌ Failed to retrieve certificate for $domain"
        return 1
    fi
    
    # Convert to epoch time
    local cert_epoch=$(date -d "$cert_date" +%s)
    local current_epoch=$(date +%s)
    local days_until_expiry=$(( (cert_epoch - current_epoch) / 86400 ))
    
    echo "Certificate expires on: $cert_date"
    echo "Days until expiry: $days_until_expiry"
    
    if [[ $days_until_expiry -lt $ALERT_DAYS ]]; then
        local message="🚨 SSL Certificate Alert: $domain expires in $days_until_expiry days!"
        echo "$message"
        
        if [[ -n "$WEBHOOK_URL" ]]; then
            curl -X POST -H 'Content-type: application/json' \
                --data "{\"text\":\"$message\"}" \
                "$WEBHOOK_URL"
        fi
        return 1
    else
        echo "✅ Certificate is valid for $days_until_expiry more days"
        return 0
    fi
}

main() {
    echo "SSL Certificate Checker"
    echo "Alert threshold: $ALERT_DAYS days"
    echo "==============================="
    
    local failed_checks=0
    
    for domain in "${DOMAINS[@]}"; do
        if ! check_certificate "$domain"; then
            ((failed_checks++))
        fi
        echo ""
    done
    
    echo "Certificate check completed. Failed checks: $failed_checks"
    exit $failed_checks
}

main "$@"
```

## Database Management Scripts

### Database Backup Script
```bash
#!/bin/bash

# db-backup.sh
set -e

DB_TYPE=${DB_TYPE:-postgresql}
DB_HOST=${DB_HOST:-localhost}
DB_PORT=${DB_PORT:-5432}
DB_NAME=${DB_NAME}
DB_USER=${DB_USER}
DB_PASSWORD=${DB_PASSWORD}
BACKUP_DIR=${BACKUP_DIR:-/backups}
RETENTION_DAYS=${RETENTION_DAYS:-7}

if [[ -z "$DB_NAME" || -z "$DB_USER" ]]; then
    echo "Error: DB_NAME and DB_USER must be set"
    exit 1
fi

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="${BACKUP_DIR}/${DB_NAME}_${TIMESTAMP}.sql"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

backup_postgresql() {
    log "Starting PostgreSQL backup..."
    
    export PGPASSWORD="$DB_PASSWORD"
    
    pg_dump -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" \
        --no-password --verbose --format=custom > "$BACKUP_FILE"
    
    if [[ $? -eq 0 ]]; then
        log "Backup completed: $BACKUP_FILE"
        
        # Compress backup
        gzip "$BACKUP_FILE"
        BACKUP_FILE="${BACKUP_FILE}.gz"
        log "Backup compressed: $BACKUP_FILE"
    else
        log "Backup failed!"
        exit 1
    fi
}

backup_mysql() {
    log "Starting MySQL backup..."
    
    mysqldump -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASSWORD" \
        --single-transaction --routines --triggers "$DB_NAME" > "$BACKUP_FILE"
    
    if [[ $? -eq 0 ]]; then
        log "Backup completed: $BACKUP_FILE"
        
        # Compress backup
        gzip "$BACKUP_FILE"
        BACKUP_FILE="${BACKUP_FILE}.gz"
        log "Backup compressed: $BACKUP_FILE"
    else
        log "Backup failed!"
        exit 1
    fi
}

cleanup_old_backups() {
    log "Cleaning up backups older than $RETENTION_DAYS days..."
    
    find "$BACKUP_DIR" -name "${DB_NAME}_*.sql.gz" -type f -mtime +$RETENTION_DAYS -delete
    
    log "Cleanup completed"
}

verify_backup() {
    if [[ -f "$BACKUP_FILE" ]]; then
        local size=$(du -h "$BACKUP_FILE" | cut -f1)
        log "Backup verification: $BACKUP_FILE ($size)"
        
        # Test if backup file is not corrupted
        if [[ "$BACKUP_FILE" == *.gz ]]; then
            if ! gzip -t "$BACKUP_FILE"; then
                log "Error: Backup file is corrupted!"
                exit 1
            fi
        fi
        
        log "Backup verification passed"
    else
        log "Error: Backup file not found!"
        exit 1
    fi
}

main() {
    log "Starting database backup for $DB_NAME"
    
    # Create backup directory if it doesn't exist
    mkdir -p "$BACKUP_DIR"
    
    # Perform backup based on database type
    case "$DB_TYPE" in
        postgresql|postgres)
            backup_postgresql
            ;;
        mysql|mariadb)
            backup_mysql
            ;;
        *)
            log "Error: Unsupported database type: $DB_TYPE"
            exit 1
            ;;
    esac
    
    # Verify backup
    verify_backup
    
    # Cleanup old backups
    cleanup_old_backups
    
    log "Database backup process completed successfully"
}

main "$@"
```

## Performance Monitoring Scripts

### System Performance Monitor
```bash
#!/bin/bash

# performance-monitor.sh
THRESHOLD_CPU=80
THRESHOLD_MEMORY=85
THRESHOLD_DISK=90
LOG_FILE="/var/log/performance-monitor.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

send_alert() {
    local message="$1"
    log "ALERT: $message"
    
    # Send to Slack if webhook is configured
    if [[ -n "$SLACK_WEBHOOK_URL" ]]; then
        curl -X POST -H 'Content-type: application/json' \
            --data "{\"text\":\"🚨 Performance Alert: $message\"}" \
            "$SLACK_WEBHOOK_URL" 2>/dev/null
    fi
}

check_cpu() {
    local cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)
    cpu_usage=${cpu_usage%.*}  # Remove decimal part
    
    log "CPU Usage: ${cpu_usage}%"
    
    if [[ $cpu_usage -gt $THRESHOLD_CPU ]]; then
        send_alert "High CPU usage: ${cpu_usage}% (threshold: ${THRESHOLD_CPU}%)"
        
        # Show top processes
        log "Top CPU consuming processes:"
        ps aux --sort=-%cpu | head -5 | tee -a "$LOG_FILE"
    fi
}

check_memory() {
    local memory_info=$(free | grep Mem)
    local total=$(echo $memory_info | awk '{print $2}')
    local used=$(echo $memory_info | awk '{print $3}')
    local memory_usage=$(( used * 100 / total ))
    
    log "Memory Usage: ${memory_usage}%"
    
    if [[ $memory_usage -gt $THRESHOLD_MEMORY ]]; then
        send_alert "High memory usage: ${memory_usage}% (threshold: ${THRESHOLD_MEMORY}%)"
        
        # Show top processes
        log "Top memory consuming processes:"
        ps aux --sort=-%mem | head -5 | tee -a "$LOG_FILE"
    fi
}

check_disk() {
    log "Disk Usage:"
    df -h | tee -a "$LOG_FILE"
    
    # Check each mounted filesystem
    while read -r line; do
        if [[ "$line" =~ ^/dev ]]; then
            local usage=$(echo "$line" | awk '{print $5}' | sed 's/%//')
            local filesystem=$(echo "$line" | awk '{print $1}')
            local mountpoint=$(echo "$line" | awk '{print $6}')
            
            if [[ $usage -gt $THRESHOLD_DISK ]]; then
                send_alert "High disk usage: $filesystem ($mountpoint) at ${usage}% (threshold: ${THRESHOLD_DISK}%)"
            fi
        fi
    done <<< "$(df -h)"
}

check_load() {
    local load_avg=$(uptime | awk -F'load average:' '{print $2}' | awk '{print $1}' | sed 's/,//')
    local cpu_cores=$(nproc)
    local load_percentage=$(echo "scale=2; $load_avg * 100 / $cpu_cores" | bc)
    
    log "Load Average: $load_avg (${load_percentage}% of ${cpu_cores} cores)"
    
    # Alert if load is above 80% of available cores
    if (( $(echo "$load_percentage > 80" | bc -l) )); then
        send_alert "High system load: $load_avg (${load_percentage}% of capacity)"
    fi
}

check_network() {
    log "Network connections:"
    netstat -tuln | grep LISTEN | wc -l | xargs echo "Listening ports:" | tee -a "$LOG_FILE"
    
    # Check for established connections
    local established=$(netstat -an | grep ESTABLISHED | wc -l)
    log "Established connections: $established"
    
    if [[ $established -gt 1000 ]]; then
        send_alert "High number of network connections: $established"
    fi
}

main() {
    log "Starting performance monitoring check"
    
    check_cpu
    check_memory
    check_disk
    check_load
    check_network
    
    log "Performance monitoring check completed"
    echo ""
}

# Run continuously if called with --daemon flag
if [[ "$1" == "--daemon" ]]; then
    while true; do
        main
        sleep 60
    done
else
    main
fi
```

## Utility Scripts

### Service Discovery Script
```bash
#!/bin/bash

# service-discovery.sh
NAMESPACE=${1:-default}
OUTPUT_FORMAT=${2:-table}

discover_services() {
    echo "Discovering services in namespace: $NAMESPACE"
    echo "============================================="
    
    case "$OUTPUT_FORMAT" in
        json)
            kubectl get services -n "$NAMESPACE" -o json
            ;;
        yaml)
            kubectl get services -n "$NAMESPACE" -o yaml
            ;;
        table|*)
            echo -e "NAME\tTYPE\tCLUSTER-IP\tEXTERNAL-IP\tPORT(S)"
            kubectl get services -n "$NAMESPACE" --no-headers | \
                awk '{printf "%-20s %-12s %-15s %-15s %s\n", $1, $2, $3, $4, $5}'
            ;;
    esac
    
    echo ""
    echo "Endpoints:"
    kubectl get endpoints -n "$NAMESPACE"
}

discover_pods() {
    echo "Pod Status in namespace: $NAMESPACE"
    echo "===================================="
    
    kubectl get pods -n "$NAMESPACE" -o wide
    
    echo ""
    echo "Pod Resource Usage:"
    kubectl top pods -n "$NAMESPACE" 2>/dev/null || echo "Metrics server not available"
}

discover_ingress() {
    echo "Ingress Resources in namespace: $NAMESPACE"
    echo "=========================================="
    
    kubectl get ingress -n "$NAMESPACE" -o wide
}

main() {
    if ! command -v kubectl &> /dev/null; then
        echo "Error: kubectl not found"
        exit 1
    fi
    
    discover_services
    echo ""
    discover_pods
    echo ""
    discover_ingress
}

main "$@"
```

These automation scripts provide comprehensive coverage of common DevOps/SRE tasks including deployments, monitoring, infrastructure management, database operations, and performance monitoring. Each script includes error handling, logging, and alerting capabilities that are essential for production environments.