#!/bin/sh
# Entrypoint с поддержкой переменных окружения

set -e

echo '=== Logrotate Container Starting ==='


# Проверяем установлен ли logrotate
if ! command -v logrotate >/dev/null 2>&1; then
    echo "ERROR: logrotate is not installed!"
    echo "Installing logrotate..."
    apk add --no-cache logrotate dcron tzdata 2>/dev/null || {
        echo "Failed to install logrotate"
        exit 1
    }
    echo "logrotate installed successfully"
fi

# Параметры из переменных окружения
CRON_SCHEDULE="${CRON_SCHEDULE:-0 2 * * *}"
RUN_AT_STARTUP="${RUN_AT_STARTUP:-false}"
MAXSIZE="${MAXSIZE:-100M}"
ROTATE_COUNT="${ROTATE_COUNT:-7}"
COMPRESS="${COMPRESS:-compress}"
MAXAGE="${MAXAGE:-90}"

echo "Configuration:"
echo "  Cron schedule: $CRON_SCHEDULE"
echo "  Run at startup: $RUN_AT_STARTUP"
echo "  Max file size: $MAXSIZE"
echo "  Rotate count: $ROTATE_COUNT"
echo "  Max archive age: $MAXAGE days"

# Создаем динамическую конфигурацию
CONFIG_FILE="/etc/logrotate.d/dynamic-config"

cat > "$CONFIG_FILE" << EOF
# Dynamic logrotate configuration
# Generated at $(date)

# Правила для логов в поддиректориях
/logs/nginx/logstash/stream/*.log {
    rotate ${ROTATE_COUNT}
    size ${MAXSIZE}
    ${COMPRESS}
    delaycompress
    missingok
    notifempty
    copytruncate
}

# Правила для логов в поддиректориях
/logs/nginx/logstash/http/*.log {
    rotate ${ROTATE_COUNT}
    size ${MAXSIZE}
    ${COMPRESS}
    delaycompress
    missingok
    notifempty
    copytruncate
}
EOF

echo "Generated configuration saved to $CONFIG_FILE"

# Проверяем конфигурацию
echo 'Testing logrotate configuration...'
if ! /usr/sbin/logrotate -d "$CONFIG_FILE" >/dev/null 2>&1; then
    echo "ERROR: Logrotate configuration test failed!"
    /usr/sbin/logrotate -d "$CONFIG_FILE"
    exit 1
fi
echo 'Configuration test passed'

# Запускаем при старте если нужно
if [ "$RUN_AT_STARTUP" = "true" ]; then
    echo 'Running logrotate at startup...'
    /usr/sbin/logrotate "$CONFIG_FILE"
    echo 'Startup rotation completed'
fi

# Настраиваем cron
echo "Setting up cron..."
echo "$CRON_SCHEDULE /usr/sbin/logrotate $CONFIG_FILE 2>&1 | logger -t logrotate" > /etc/crontabs/root

echo "Cron jobs configured:"
crontab -l


echo '=== Starting cron daemon ==='
# Создаем лог-файл для cron
CRON_LOG="/var/log/cron.log"
touch "$CRON_LOG"
# Запускаем crond в фоне
echo "Starting crond with logging to $CRON_LOG..."
crond -l 8 -f > "$CRON_LOG" 2>&1 &
echo "=== Tailing cron logs ==="
tail -f "$CRON_LOG"
