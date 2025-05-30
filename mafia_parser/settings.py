# mafia_parser/settings.py
BOT_NAME = 'mafia_parser'

SPIDER_MODULES = ['mafia_parser.spiders']
NEWSPIDER_MODULE = 'mafia_parser.spiders'

# Минимальные настройки для экономии памяти
ROBOTSTXT_OBEY = True
DOWNLOAD_DELAY = 3
CONCURRENT_REQUESTS = 1
CONCURRENT_REQUESTS_PER_DOMAIN = 1

# Отключаем ненужное
TELNETCONSOLE_ENABLED = False
COOKIES_ENABLED = False

# Подробные логи для отладки
LOG_LEVEL = 'DEBUG'  # Больше логов
LOG_FILE = '/var/log/scrapy.log'
LOG_FILE_APPEND = False  # Перезаписываем каждый раз

# Логируем статистику
STATS_CLASS = 'scrapy.statscollectors.MemoryStatsCollector'

# User-Agent
USER_AGENT = 'mafia_parser (+https://github.com/your-repo)'

# Показываем больше информации в логах
LOG_SHORT_NAMES = False