#!/bin/sh
# Скрипт для полной очистки логов

set -e

LOG_DIR="${1:-/logs}"

echo "=== Starting log cleanup ==="
echo "Directory: $LOG_DIR"

# Проверяем существование директории
if [ ! -d "$LOG_DIR" ]; then
    echo "ERROR: Directory $LOG_DIR does not exist!"
    exit 1
fi

# 1. Очищаем ВСЕ .log файлы
echo "1. Clearing all .log files..."
log_count=0
find "$LOG_DIR" -name '*.log' -type f | while read file; do
    size_before=$(stat -c%s "$file" 2>/dev/null || echo 0)
    > "$file"  # Полная очистка файла
    size_after=$(stat -c%s "$file" 2>/dev/null || echo 0)
    echo "  ✓ $(basename "$file"): ${size_before} bytes → ${size_after} bytes"
    log_count=$((log_count + 1))
done

echo "   Total .log files cleared: $log_count"

# 2. Удаляем старые архивы (если указано количество дней)
if [ "$DELETE_ARCHIVES" = "true" ] && [ -n "$DELETE_ARCHIVES" ]; then
    echo "2. Deleting old .gz archives..."
    archive_count=0
    find "$LOG_DIR" -name '*.gz' -type f | while read file; do
        rm -f "$file"
        echo "  ✗ Deleted: $(basename "$file")"
        archive_count=$((archive_count + 1))
    done
    echo "   Total .gz archives deleted: $archive_count"
else
    echo "2. Skipping archive deletion (DELETE_ARCHIVES=$DELETE_ARCHIVES)"
fi

echo "=== Log cleanup completed successfully ==="
echo "Total disk usage after cleanup:"
du -sh "$LOG_DIR" 2>/dev/null || echo "Cannot get disk usage"