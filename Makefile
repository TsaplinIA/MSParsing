# Makefile
.PHONY: start stop logs test status monitor

start:
	@echo "🚀 Запуск парсера..."
	docker compose up -d
	@echo "✅ Готово! Парсинг каждую минуту."

stop:
	@echo "🛑 Остановка..."
	docker compose down

logs:
	docker compose logs -f

# Детальные логи всех типов
logs-all:
	@echo "📋 Cron логи:"
	@docker compose exec mafia-parser tail -20 /var/log/cron.log 2>/dev/null || echo "❌ Cron логи недоступны"
	@echo ""
	@echo "📋 Scrapy логи:"
	@docker compose exec mafia-parser tail -20 /var/log/scrapy.log 2>/dev/null || echo "❌ Scrapy логи недоступны"
	@echo ""
	@echo "📋 Тестовые логи:"
	@docker compose exec mafia-parser tail -20 /var/log/test.log 2>/dev/null || echo "❌ Тестовые логи недоступны"

# Только cron логи
logs-cron:
	docker compose exec mafia-parser tail -f /var/log/cron.log

# Тест (одноразовый запуск)
test:
	@echo "🧪 Тестовый запуск..."
	docker run --rm -v $(PWD)/data:/data -w /app \
		python:3.9-alpine sh -c \
		"pip install scrapy && \
		 scrapy crawl mafia"

# Статус и результаты
status:
	@echo "📊 Mafia Parser Status"
	@echo "======================"
	@if docker compose ps -q mafia-parser | grep -q .; then \
		echo "✅ Контейнер: ЗАПУЩЕН"; \
		echo "🔄 Статус: $(docker compose ps mafia-parser --format 'table {{.State}}' | tail -1)"; \
		echo "⏰ Время работы: $(docker inspect mafia-parser --format '{{.State.StartedAt}}' 2>/dev/null | cut -d'T' -f2 | cut -d'.' -f1)"; \
	else \
		echo "❌ Контейнер: ОСТАНОВЛЕН"; \
	fi
	@echo ""
	@echo "📁 Файлы данных: $(ls -1 ./data/*.json 2>/dev/null | wc -l) файлов"
	@echo "💾 Размер данных: $(du -sh ./data 2>/dev/null | cut -f1)"
	@echo ""
	@echo "📋 Последний результат:"
	@if [ -f ./data/latest.json ]; then \
		echo "   Время: $(cat ./data/latest.json | python3 -c "import sys,json; print(json.load(sys.stdin)['timestamp'])" 2>/dev/null)"; \
		cat ./data/latest.json | python3 -c "import sys,json; [print(f\"   {p['position']}. {p['nickname']} - {p['rating']}\") for p in json.load(sys.stdin)['top3']]" 2>/dev/null; \
	else \
		echo "❌ Результатов пока нет"; \
	fi

# Мониторинг ресурсов
monitor:
	@echo "💾 Использование дискового пространства:"
	@du -sh ./data
	@echo ""
	@echo "📁 Количество файлов:"
	@ls -la ./data | wc -l
	@echo ""
	@echo "🐳 Статистика контейнера:"
	@docker stats mafia-parser --no-stream

# Ручной запуск паука
run:
	docker compose exec mafia-parser scrapy crawl mafia

# Очистка (оставляет только последние 10 архивов)
clean:
	@echo "🧹 Очистка старых архивов..."
	@find ./data -name "archive_*.json" -type f | head -n -10 | xargs rm -f
	@echo "✅ Очистка завершена"

# Полная очистка
clean-all:
	rm -rf ./data/*
	docker compose down -v