from .production import *

# Для возможности работы тестов Selenium с помощью удаленного сервиса
# ALLOWED_HOSTS.append(os.environ.get('ALLOWED_WEB_HOST'))
# ALLOWED_HOSTS.append('localhost')
# ALLOWED_HOSTS.append('127.0.0.1')

MIGRATION_MODULES = {
    'auth': None,
    'contenttypes': None,
    'default': None,
    'sessions': None,

    'core': None
}
