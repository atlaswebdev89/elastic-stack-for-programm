#!/bin/sh
# Основной entrypoint для контейнера
set -e

# Если переданы аргументы - используем их
if [ $# -gt 0 ]; then
    # Пользователь хочет запустить свою команду
    exec "$@"
else
    # Автоматическая очистка по умолчанию
    if [ "${CLEAR_LOGS:-true}" = "true" ]; then
        /scripts/clear-logs.sh "/logs" "${DELETE_ARCHIVES:-false}"
    else
        echo "CLEAR_LOGS is set to false, skipping automatic cleanup"
    fi
fi