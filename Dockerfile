FROM python:3.9-alpine

WORKDIR /app

# Устанавливаем только необходимое
RUN apk add --no-cache \
    gcc \
    musl-dev \
    libxml2-dev \
    libxslt-dev \
    dcron \
    logrotate \
    && pip install --no-cache-dir scrapy

# Копируем проект
COPY . .

# Настраиваем logrotate
COPY logrotate.conf /etc/logrotate.d/mafia-parser

# Настраиваем cron
RUN echo "* * * * * cd /app && scrapy crawl mafia >> /var/log/cron.log 2>&1" | crontab - && \
    echo "0 * * * * /usr/sbin/logrotate /etc/logrotate.d/mafia-parser" | crontab -

# Создаем директории
RUN mkdir -p /data /var/log

# Стартовый скрипт
COPY start.sh /start.sh
RUN chmod +x /start.sh

CMD ["/start.sh"]