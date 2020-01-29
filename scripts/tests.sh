#!/bin/sh
# Скрипт выполняется однократно при запуске контейнера -
# ожидается доступность базы данных, выполняются миграции и тесты

echo "\e[96mWaiting for postgres...\e[0m"

while ! nc -z $DB_HOST $DB_PORT; do
  sleep 0.5
done

# https://www.opennet.ru/cgi-bin/opennet/man.cgi?topic=sh&category=1
set -e

echo "\e[96mDatabase started, applying migrations...\e[0m"
python -B manage.py migrate --no-input 2>&1
# TODO: Разобраться, почему в stdout в Job-ах не выводится, если есть изменение моделей.
# echo "\e[96mDouble check for unapplyed model changes\e[0m"
# python -B manage.py migrate --no-input
echo "\e[96mCheck Django structure...\e[0m"
python manage.py check --deploy --settings=src.core.settings --fail-level WARNING
echo "\e[96mCleaning old log files...\e[0m"
rm -rf /app/test-logs || true
echo "\e[96mDone\e[0m"
echo "\e[96mStarting tests...\e[0m"
python manage.py test --settings=src.core.settings --noinput
exec "$@"