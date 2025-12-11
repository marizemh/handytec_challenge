#!/bin/bash

# Advanced Health Check Script
# Usage: ./health_check.sh [--json|--csv] [--fix]

set -e

# Configuration
THRESHOLD_CPU=80
THRESHOLD_MEM=80
THRESHOLD_DISK=90
SERVICE_NAME="docker" # Using docker as an example service to check
ALERT_WEBHOOK_URL="https://hooks.slack.com/services/XXX/YYY/ZZZ" # Mock URL

# Flags
OUTPUT_FORMAT="text"
AUTO_FIX=false

# Parse arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --json) OUTPUT_FORMAT="json" ;;
        --csv) OUTPUT_FORMAT="csv" ;;
        --fix) AUTO_FIX=true ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

# Metrics Collection
get_cpu_usage() {
    top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}'
}

get_mem_usage() {
    free | grep Mem | awk '{print $3/$2 * 100.0}'
}

get_disk_usage() {
    df -h / | tail -1 | awk '{print $5}' | sed 's/%//'
}

check_service() {
    if systemctl is-active --quiet "$SERVICE_NAME"; then
        echo "active"
    else
        echo "inactive"
    fi
}

# Remediation
restart_service() {
    echo "Attempting to restart $SERVICE_NAME..." >&2
    # In a real scenario, run with sudo or appropriate permissions
    # sudo systemctl restart "$SERVICE_NAME"
    echo "Service restart triggered (Simulation)." >&2
}

cleartmp() {
    echo "Cleaning up /tmp..." >&2
    # rm -rf /tmp/*
    echo "/tmp cleanup triggered (Simulation)." >&2
}

# Alerting
send_alert() {
    local message="$1"
    echo "ALERT SENT: $message" >&2
    # curl -X POST -H 'Content-type: application/json' --data "{\"text\":\"$message\"}" "$ALERT_WEBHOOK_URL"
}

# Main Logic
CPU_USAGE=$(get_cpu_usage)
MEM_USAGE=$(get_mem_usage)
DISK_USAGE=$(get_disk_usage)
SERVICE_STATUS=$(check_service)

# Check Thresholds & Fix
STATUS="OK"
ISSUES=()

if (( $(echo "$CPU_USAGE > $THRESHOLD_CPU" | bc -l) )); then
    ISSUES+=("High CPU: $CPU_USAGE%")
    STATUS="CRITICAL"
fi

if (( $(echo "$MEM_USAGE > $THRESHOLD_MEM" | bc -l) )); then
    ISSUES+=("High Memory: $MEM_USAGE%")
    STATUS="CRITICAL"
fi

if [ "$DISK_USAGE" -gt "$THRESHOLD_DISK" ]; then
    ISSUES+=("High Disk: $DISK_USAGE%")
    STATUS="CRITICAL"
    if [ "$AUTO_FIX" = true ]; then
        cleartmp
    fi
fi

if [ "$SERVICE_STATUS" != "active" ]; then
    ISSUES+=("Service $SERVICE_NAME is down")
    STATUS="CRITICAL"
    if [ "$AUTO_FIX" = true ]; then
        restart_service
        # Recheck
        if systemctl is-active --quiet "$SERVICE_NAME"; then
             ISSUES+=("Service $SERVICE_NAME restarted successfully")
        else
             ISSUES+=("Service $SERVICE_NAME failed to restart")
             send_alert "CRITICAL: Service $SERVICE_NAME is down and auto-fix failed on $(hostname)"
        fi
    fi
    send_alert "CRITICAL: Service $SERVICE_NAME went down on $(hostname)"
fi

# Output
timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

if [ "$OUTPUT_FORMAT" == "json" ]; then
    cat <<EOF
{
  "timestamp": "$timestamp",
  "hostname": "$(hostname)",
  "status": "$STATUS",
  "metrics": {
    "cpu": $CPU_USAGE,
    "memory": $MEM_USAGE,
    "disk": $DISK_USAGE
  },
  "service": {
    "name": "$SERVICE_NAME",
    "status": "$SERVICE_STATUS"
  },
  "issues": [$(IFS=,; echo "\"${ISSUES[*]}\"")]
}
EOF
elif [ "$OUTPUT_FORMAT" == "csv" ]; then
    echo "timestamp,hostname,status,cpu,memory,disk,service_status,issues"
    echo "$timestamp,$(hostname),$STATUS,$CPU_USAGE,$MEM_USAGE,$DISK_USAGE,$SERVICE_STATUS,\"${ISSUES[*]}\""
else
    echo "Health Check Report - $timestamp"
    echo "--------------------------------"
    echo "Hostname: $(hostname)"
    echo "Status: $STATUS"
    echo "CPU: $CPU_USAGE%"
    echo "Memory: $MEM_USAGE%"
    echo "Disk: $DISK_USAGE%"
    echo "Service ($SERVICE_NAME): $SERVICE_STATUS"
    if [ ${#ISSUES[@]} -gt 0 ]; then
        echo "Issues Found:"
        printf ' - %s\n' "${ISSUES[@]}"
    fi
fi
