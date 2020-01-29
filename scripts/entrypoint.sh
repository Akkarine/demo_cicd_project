#!/bin/sh
# Скрипт выполняется однократно при запуске контейнера -
# ожидается доступность базы данных и выполняются миграции.

echo "\e[96mWaiting for postgres...\e[0m"

while ! nc -z $DB_HOST $DB_PORT; do
  sleep 0.1
done

set -e

echo "\e[96mPostgreSQL started, applying migrations...\e[0m"
python -B manage.py migrate --no-input
echo "\e[96mBackend ready.\e[0m"

exec "$@"