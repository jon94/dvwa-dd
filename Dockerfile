FROM docker.io/library/php:8-apache

LABEL org.opencontainers.image.source=https://github.com/digininja/DVWA
LABEL org.opencontainers.image.description="DVWA pre-built image."
LABEL org.opencontainers.image.licenses="gpl-3.0"

WORKDIR /var/www/html

# Set environment variables for Datadog APM
ENV DD_ENV=bruteforce
ENV DD_SERVICE=dvwa
ENV DD_VERSION=1

# https://www.php.net/manual/en/image.installation.php
RUN apt-get update \
 && export DEBIAN_FRONTEND=noninteractive \
 && apt-get install -y zlib1g-dev libpng-dev libjpeg-dev libfreetype6-dev iputils-ping \
 && apt-get clean -y && rm -rf /var/lib/apt/lists/* \
 && docker-php-ext-configure gd --with-jpeg --with-freetype \
 # Use pdo_sqlite instead of pdo_mysql if you want to use sqlite
 && docker-php-ext-install gd mysqli pdo pdo_mysql

COPY --chown=www-data:www-data . .
COPY --chown=www-data:www-data config/config.inc.php.dist config/config.inc.php

# Install Datadog tracer and activate
RUN curl -LO https://github.com/DataDog/dd-trace-php/releases/latest/download/datadog-setup.php \
 && php datadog-setup.php --php-bin=all --enable-appsec

# Set up Apache configuration to use environment variables
RUN echo '<VirtualHost *:80>\n\
    DocumentRoot /var/www/html\n\
    <Directory /var/www/html>\n\
        AllowOverride All\n\
        Require all granted\n\
    </Directory>\n\
    SetEnv DD_AGENT_HOST ${DD_AGENT_HOST}\n\
    SetEnv DD_ENV ${DD_ENV}\n\
    SetEnv DD_APPSEC_ENABLED ${DD_APPSEC_ENABLED}\n\
    SetEnv DD_SERVICE ${DD_SERVICE}\n\
    SetEnv DD_VERSION ${DD_VERSION}\n\
    SetEnv DD_APPSEC_AUTOMATED_USER_EVENTS_TRACKING ${DD_APPSEC_AUTOMATED_USER_EVENTS_TRACKING}\n\
    ErrorLog ${APACHE_LOG_DIR}/error.log\n\
    CustomLog ${APACHE_LOG_DIR}/access.log combined\n\
</VirtualHost>' > /etc/apache2/sites-available/000-default.conf

# Ensure Apache runs in the foreground
CMD ["apache2-foreground"]
