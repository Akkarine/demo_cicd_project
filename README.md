# Демо-проект для доклада


### Установка зависимостей 📦
``` bash
# установка pipenv и python-зависимостей
pip3 install pipenv
pipenv install
```

### Запуск сервера
``` bash
# запуск бекенда с горячей перезагрузкой на localhost:8000
pipenv run python3 manage.py runserver 8000
```

### Переменные среды для манипуляции настройками бекенда 🔧
```
DEBUG=True|False            # Включение отладки. По-умолчанию: False

ALLOWED_WEB_HOST            # Разрешенное значение заголовка HOST.
                            # Не влияет при отладке. По-умолчанию: localhost

DB_HOST                     # Имя хоста Postgres. По-умолчанию: localhost

DB_PORT                     # Порт базы данных Postgres. По-умолчанию: 5432

DB_NAME                     # Название БД Postgres. По-умолчанию: demo

DB_USER                     # Название пользователя БД. По-умолчанию: demo

DB_PASSWORD                 # Пароль пользователя БД. По-умолчанию: demo

STATIC_ROOT                 # Абсолютный путь к папке со статическим содержимым
                            # По-умолчанию: /app/static
```

### Ресурсы для изучения/использования 🧐
- [Django 2.2](https://docs.djangoproject.com/en/2.2/)

#### Проект неразрывно связан с инфраструктурой.
* Репозиторий: https://github.com/Akkarine/demo_cicd

#### Нужно сделать для создания рабочего процесса разработки:
1. Создать rsa-key на production сервере для доступа на сервер бэкапа: https://serverfault.com/a/330740/536744 (просто сгенерить и загрузить в пользователя)
2. Создать в GitLab расписание для обновления образа бд для staging
   * https://docs.gitlab.com/ee/user/project/pipelines/schedules.html
3. Создать переменные проекта на GitLab:
   * Для работы приложения в тестовом и production окружениях:
      * STAGING_ALLOWED_WEB_HOST
      * PRODUCTION_ALLOWED_WEB_HOST
   * Для обращения к серверу с ежечасными бэкапами БД (доступ оп ssh):
      * BACKUP_DB_SERVER_USER
      * BACKUP_DB_SERVER_PASSWORD
      * BACKUP_DB_SERVER_IP - ip адрес сервера
      * BACKUP_DB_SERVER_PATH - абсолютный путь к бэкапам без последнего слеша
