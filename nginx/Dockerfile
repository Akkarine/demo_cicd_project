# https://github.com/nginxinc/docker-nginx/blob/master/stable/buster/Dockerfile
FROM nginx:1.17.4
ENV TZ=${TZ:-Europe/Volgograd}

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone \
    && apt-get update -q -y \
    && DEBIAN_FRONTEND=noninteractive apt-get install -q -y --no-install-recommends --no-install-suggests \
    tzdata \
    locales \
    && apt-get -y --purge autoremove \
    && rm -rf /var/lib/apt/lists/* \
    && echo "ru_RU.UTF-8 UTF-8" > /etc/locale.gen \
    && locale-gen \
    && update-locale LANG=ru_RU.UTF-8 \
    && rm /etc/nginx/conf.d/default.conf

COPY demo.nginx /etc/nginx/