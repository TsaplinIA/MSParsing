#!/bin/sh

echo "🚀 Запуск Mafia Parser..."
echo "📅 Время: $(date)"
echo "🌍 Timezone: $TZ"

# Создаем файлы логов если их нет
touch /var/log/cron.log /var/log/scrapy.log
echo "📁 Логи созданы"

# Проверяем crontab
echo "⏰ Проверка crontab:"
crontab -l

# Тестовый запуск scrapy
echo "🧪 Тестовый запуск scrapy..."
cd /app
scrapy crawl mafia 2>&1 | tee /var/log/test.log
echo "✅ Тестовый запуск завершен"

# Запускаем cron в фоне
echo "🔄 Запуск cron daemon..."
crond -f -d 8 &
CRON_PID=$!
echo "📋 Cron PID: $CRON_PID"

# Ждем немного и проверяем cron
sleep 5
if kill -0 $CRON_PID 2>/dev/null; then
    echo "✅ Cron работает"
else
    echo "❌ Cron не запустился!"
fi

# Показываем логи с дополнительной информацией
echo "📋 Мониторинг логов (с отметками времени):"
tail -f /var/log/cron.log | while read line; do
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $line"

    # Проверяем размер лога каждые 50 строк
    if [ $(($(wc -l < /var/log/cron.log) % 50)) -eq 0 ]; then
        if [ $(wc -l < /var/log/cron.log) -gt 5000 ]; then
            tail -1000 /var/log/cron.log > /tmp/cron.log.tmp
            mv /tmp/cron.log.tmp /var/log/cron.log
            echo "[$(date '+%Y-%m-%d %H:%M:%S')] 🔄 Лог обрезан до последних 1000 строк"
        fi
    fi
done