# mafia_parser/spiders/mafia.py
import scrapy
import re
import json
import os
import glob
from datetime import datetime


class MafiaSpider(scrapy.Spider):
    name = 'mafia'
    start_urls = ['https://mafiastyle.pythonanywhere.com/']

    # Легкие настройки для слабого VPS
    custom_settings = {
        'DOWNLOAD_DELAY': 3,
        'CONCURRENT_REQUESTS': 1,
        'CONCURRENT_REQUESTS_PER_DOMAIN': 1,
        # Отключаем автоматическое создание файлов каждый запуск
    }

    def parse(self, response):
        rows = response.css('table.leaderboard tbody tr')[:3]

        top3 = []
        for i, row in enumerate(rows, 1):
            nickname_raw = row.css('td:nth-child(2) a::text').get()
            rating_raw = row.css('td:nth-child(3)::text').get()

            if nickname_raw and rating_raw:
                nickname = re.sub(r'[👑⚡🔥]', '', nickname_raw).strip()
                rating = float(rating_raw.strip())

                player = {
                    'name': nickname,
                    'score': str(rating)
                }

                top3.append(player)
                yield player

        # Сохраняем последний результат (только массив top3)
        with open('/data/latest.json', 'w', encoding='utf-8') as f:
            json.dump(top3, f, ensure_ascii=False, indent=2)

        # Архивируем только при изменениях
        self.archive_if_changed(top3)

        self.logger.info(f"✅ Парсинг завершен: {len(top3)} игроков")

    def archive_if_changed(self, current_top3):
        """Создает архивный файл только если данные изменились"""
        try:
            self.logger.info("🗃️ Проверяем необходимость архивации...")

            # Проверяем последний архивный файл
            files = glob.glob('/data/archive_*.json')
            self.logger.info(f"📁 Найдено архивных файлов: {len(files)}")

            if files:
                latest_archive = max(files, key=os.path.getctime)
                self.logger.info(f"📄 Последний архив: {os.path.basename(latest_archive)}")

                with open(latest_archive, 'r', encoding='utf-8') as f:
                    last_data = json.load(f)

                # Сравниваем топ-3
                if last_data == current_top3:
                    self.logger.info("🔄 Данные не изменились, архив не создаем")
                    return
                else:
                    self.logger.info("🆕 Данные изменились, создаем новый архив")
            else:
                self.logger.info("📁 Архивных файлов нет, создаем первый")

            # Создаем архивный файл с timestamp
            timestamp = datetime.now().strftime('%Y%m%d_%H%M')
            archive_file = f'/data/archive_{timestamp}.json'

            with open(archive_file, 'w', encoding='utf-8') as f:
                json.dump(current_top3, f, ensure_ascii=False, indent=2)

            self.logger.info(f"✅ Создан архив: {os.path.basename(archive_file)}")

            # Очищаем старые архивы (оставляем последние 30)
            self.cleanup_old_archives()

        except Exception as e:
            self.logger.error(f"❌ Ошибка архивации: {e}")
            import traceback
            self.logger.error(f"📋 Traceback: {traceback.format_exc()}")

    def cleanup_old_archives(self):
        """Удаляет старые архивы, оставляет последние 30"""
        try:
            files = glob.glob('/data/archive_*.json')
            self.logger.info(f"🧹 Проверка архивов: {len(files)} файлов")

            if len(files) > 30:
                files.sort(key=os.path.getctime)
                to_delete = files[:-30]

                for old_file in to_delete:
                    os.remove(old_file)
                    self.logger.info(f"🗑️ Удален: {os.path.basename(old_file)}")

                self.logger.info(f"✅ Удалено {len(to_delete)} старых архивов")
            else:
                self.logger.info("✅ Очистка архивов не требуется")

        except Exception as e:
            self.logger.error(f"❌ Ошибка очистки архивов: {e}")
            import traceback
            self.logger.error(f"📋 Traceback: {traceback.format_exc()}")

    def cleanup_old_files(self):
        """Метод больше не нужен - удален"""
        pass