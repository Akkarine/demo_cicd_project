FROM postgres:12.0 as common
# TODO: Передавать секретную инфу через файл, подмонтированный к контейнеру. А ещё лучше - через Vault.
# TODO: Возможно использовать Postgres secrets: https://hub.docker.com/_/postgres
# TODO: https://docs.docker.com/compose/compose-file/#secrets
ARG BACKUP_DB_SERVER_IP
ARG BACKUP_DB_SERVER_PATH
ARG BACKUP_DB_SERVER_USER
ARG BACKUP_DB_SERVER_PASSWORD

ENV TZ=${TZ:-Europe/Volgograd} \
    DB_NAME=${DB_NAME:-demo} \
    DB_USER=${DB_USER:-demo} \
    DB_PASSWORD=${DB_PASSWORD:-demo} \
    POSTGRES_USER=${POSTGRES_USER:-postgres} \
    POSTGRES_PASSWORD=${POSTGRES_PASSWORD:-postgres} \
    BACKUP_DB_SERVER_IP=$BACKUP_DB_SERVER_IP \
    BACKUP_DB_SERVER_PATH=$BACKUP_DB_SERVER_PATH \
    BACKUP_DB_SERVER_USER=$BACKUP_DB_SERVER_USER \
    BACKUP_DB_SERVER_PASSWORD=$BACKUP_DB_SERVER_PASSWORD

# TODO: можно ускорить, если взять/сделать готовый образ с ssh, tzdata, openssh-client - держать его в registry. Попробовать сделать в Alpine.
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone \
    && apt-get update -q -y \
    && DEBIAN_FRONTEND=noninteractive apt-get install -q -y --no-install-recommends --no-install-suggests \
    tzdata \
    openssh-client \
    && apt-get -y --purge autoremove \
    && rm -rf /var/lib/apt/lists/*
# https://stackoverflow.com/a/56646631/8537739
COPY pg.conf /tmp/pg.conf
COPY init_user.sh /docker-entrypoint-initdb.d/0_init_user.sh


FROM common as temp-dev
# TODO: Б - Безопасность (надо монтировать такое)
COPY backup_id_rsa /backup_id_rsa
# Чтобы не кэшировался образ БД с одним и тем же бэкапом
ARG BUILD_TIME
# Получение последнего файла в папке бэкапов
RUN chmod 600 backup_id_rsa \
    && latest_file=$(ssh -o StrictHostKeyChecking=no -i /backup_id_rsa $BACKUP_DB_SERVER_USER@$BACKUP_DB_SERVER_IP \
    "find $BACKUP_DB_SERVER_PATH/ -type f -printf \"%T@ %p\\n\" | sort -n | cut -d' ' -f 2- | tail -n 1") \
    && echo "Разворачивается БД из бэкапа $latest_file" \
    && scp -o StrictHostKeyChecking=no -i /backup_id_rsa $BACKUP_DB_SERVER_USER@$BACKUP_DB_SERVER_IP:$latest_file backup.sql.gz
    && rm /backup_id_rsa


FROM common as dev
# Создаётся образ для разработки - берется база с бэкап-сервера.
# Делаем так для уменьшения слоёв в конечном образе и исключения файла backup_id_rsa из истории
# Меняем путь к данным, т.к. по дефолтному пути поднимается временный VOLUME при каждом старте образа
# Таким будет проинициализированный образ БД
ENV PGDATA /db_data
COPY --from=temp-dev /backup.sql.gz /docker-entrypoint-initdb.d/9_backup.sql.gz


FROM common as production
# Образ для production - с ежечасным созданием бэкапа.
# Предполагается, что на проде есть сгенеренный ssh ключ на сервер бэкапов,
# так что случайное использование образа на другой машине не должно затереть бэкапы
# TODO: перейти на единую систему бэкапов с PITR.
# echo "1 */3,6-18 * * * root /backup.sh" >> /etc/crontab
# cron в докере не самая простая вещь в настройке и контроле
COPY backup.sh /backup.sh
RUN cat /tmp/pg.conf >> /usr/share/postgresql/postgresql.conf.sample \
    && chmod 755 backup.sh