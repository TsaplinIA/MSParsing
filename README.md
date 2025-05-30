# 🎯 Mafia Leaderboard Parser

<div align="center">

![Mafia](https://img.shields.io/badge/Game-Mafia-red?style=for-the-badge&logo=target)
![Docker](https://img.shields.io/badge/Docker-Ready-blue?style=for-the-badge&logo=docker)

**Автоматический парсер топ-3 игроков с сайта Mafia Style**

</div>

## 📖 Описание

Парсер автоматически извлекает топ-3 игроков с сайта mafiastyle.pythonanywhere.com каждую минуту. Сохраняет никнейм и рейтинг в JSON формате.

## ⭐ Возможности

- 🚀 **Автоматический парсинг** каждую минуту
- 💾 **Умная архивация** — файлы создаются только при изменениях
- 🔄 **Автоочистка** логов и старых данных
- 📊 **Минимальное потребление** — 50-100MB RAM

## 🏁 Использование

```bash
# Запуск
git clone <repository-url>
cd MSParser
make start

# Управление
make status     # Статус и последние результаты
make logs       # Логи в реальном времени
make monitor    # Мониторинг ресурсов
make stop       # Остановка
```

## 📊 Результаты

### Актуальные данные
**`data/latest.json`** — обновляется каждую минуту:
```json
[
  {
    "name": "Интеграл",
    "score": "23.38"
  },
  {
    "name": "Брюс", 
    "score": "16.69"
  },
  {
    "name": "ФанФан Тюльпан",
    "score": "16.48"
  }
]
```

### Архив изменений
**`data/archive_YYYYMMDD_HHMM.json`** — создается только при изменении топ-3:
- `archive_20250530_1445.json` — данные когда рейтинг изменился в 14:45
- `archive_20250530_1823.json` — данные когда рейтинг изменился в 18:23

## ⚙️ Настройка

**Изменить интервал парсинга** в `Dockerfile`:
```dockerfile
# Каждые 5 минут вместо каждой минуты
RUN echo "*/5 * * * * cd /app && scrapy crawl mafia >> /var/log/cron.log 2>&1" | crontab -
```

**Изменить количество архивов** в `mafia_parser/spiders/mafia.py`:
```python
# Сохранять 50 архивов вместо 30
if len(files) > 50:
```

## 📈 Мониторинг

```bash
# Статус с последними результатами
make status
```

**Пример вывода:**
```
📊 Mafia Parser Status
======================
✅ Контейнер: ЗАПУЩЕН
📁 Файлы данных: 12 архивов
💾 Размер данных: 180K

📋 Последний результат:
   1. Интеграл - 23.38
   2. Брюс - 16.69
   3. ФанФан Тюльпан - 16.48
```

---

<div align="center">

**🎯 Готов к использованию! Просто запустите `make start`**

</div>