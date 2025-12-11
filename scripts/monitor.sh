#!/bin/bash

# Handytec Challenge - Monitoring Script
# Author: DevOps Engineer
# Description: Checks failed services, RAM, and Disk space on AlmaLinux (or RHEL-based systems).

echo "========================================================"
echo "          SYSTEM HEALTH CHECK REPORT"
echo "========================================================"
date
echo ""

# 1. Check for Failed Services
echo "--------------------------------------------------------"
echo "FAILED SERVICES:"
echo "--------------------------------------------------------"
FAILED_SERVICES=$(systemctl list-units --state=failed --no-legend)

if [ -z "$FAILED_SERVICES" ]; then
    echo "OK: No failed services found."
else
    echo "WARNING: The following services are in a failed state:"
    systemctl list-units --state=failed
fi
echo ""

# 2. Check RAM Memory
echo "--------------------------------------------------------"
echo "RAM MEMORY USAGE:"
echo "--------------------------------------------------------"
free -h
echo ""
# Calculate percentage
TOTAL_MEM=$(free | grep Mem | awk '{print $2}')
USED_MEM=$(free | grep Mem | awk '{print $3}')
PERCENT_MEM=$(( 100 * USED_MEM / TOTAL_MEM ))
echo "Memory Usage: $PERCENT_MEM%"
echo ""

# 3. Check Available Disk Space by Partitions
echo "--------------------------------------------------------"
echo "DISK SPACE USAGE:"
echo "--------------------------------------------------------"
df -hT --exclude-type=tmpfs --exclude-type=devtmpfs
echo ""
echo "Partitions with usage > 80%:"
df -h --output=pcent,target | grep -v Use | awk -F'%' '{if ($1 > 80) print $0}' || echo "None"
echo ""

# 4. General System Health (Load Average)
echo "--------------------------------------------------------"
echo "SYSTEM LOAD:"
echo "--------------------------------------------------------"
uptime
echo ""

echo "========================================================"
echo "          END OF REPORT"
echo "========================================================"
