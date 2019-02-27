FROM php:7.0-apache

ENV TZ=Europe/Paris
# Set Server timezone.
RUN echo $TZ > /etc/timezone
RUN dpkg-reconfigure -f noninteractive tzdata
RUN echo date.timezone = $TZ > /usr/local/etc/php/conf.d/docker-php-ext-timezone.ini

# Install Tools
RUN apt-get update && apt-get -y install build-essential \
        htop \
        libcurl3 \
        libcurl3-dev \
        librecode0 \
        libsqlite3-0 \
        libxml2 \
        curl \
        wget \
        python \
        vim \
        nano \
        cron \
        git \
        unzip \
        autoconf \
        file \
        g++ \
        gcc \
        libc-dev \
        make \
        pkg-config \
        re2c \
        bison \
		apt-utils \
		ghostscript \
        ca-certificates --no-install-recommends

# Install PHP 7 Extension
RUN apt-get update && apt-get install -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libpng-dev \
        libsqlite3-dev \
        libssl-dev \
        libcurl3-dev \
        libxml2-dev \
        libzzip-dev \
        libldap2-dev  \
        libicu-dev \
        libxslt-dev \
        libc-client-dev \
        libkrb5-dev \
        libxml2-dev \
        libpcre3-dev \
    && docker-php-ext-install calendar bcmath mcrypt intl mysqli pdo_mysql xmlrpc zip soap \
	&& docker-php-ext-configure opcache --enable-opcache && docker-php-ext-install opcache \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install gd

# Enable Apache mod_rewrite
RUN a2enmod rewrite

# Set up composer variables
ENV COMPOSER_ALLOW_SUPERUSER=1
ENV COMPOSER_BINARY=/usr/local/bin/composer \
    COMPOSER_HOME=/usr/local/composer
ENV PATH $PATH:$COMPOSER_HOME

# Install composer system-wide
RUN curl -sS https://getcomposer.org/installer | php && \
    mv composer.phar $COMPOSER_BINARY && \
    chmod +x $COMPOSER_BINARY

# Install composer global package
RUN composer global require "fxp/composer-asset-plugin:1.4.*"

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# set recommended PHP.ini settings
# see https://secure.php.net/manual/en/opcache.installation.php
RUN { \
		echo 'opcache.memory_consumption=256'; \
		echo 'opcache.interned_strings_buffer=8'; \
		echo 'opcache.max_accelerated_files=4000'; \
		echo 'opcache.revalidate_freq=2'; \
		echo 'opcache.fast_shutdown=1'; \
		echo 'opcache.enable_cli=1'; \
		echo 'opcache.enable=1'; \
	} > /usr/local/etc/php/conf.d/opcache-recommended.ini

RUN { \
        echo 'max_execution_time = 30'; \
        echo 'error_reporting =  E_ALL'; \
        echo 'log_errors = On'; \
        echo 'display_errors = Off'; \
        echo 'memory_limit = 2048M'; \
		echo 'date.timezone = Europe/Paris'; \
		echo 'soap.wsdl_cache = 0'; \
		echo 'soap.wsdl_cache_enabled = 0'; \
		echo 'post_max_size = 100M'; \
		echo 'upload_max_filesize = 100M'; \
    } > /usr/local/etc/php/php.ini

# Create Volume
VOLUME ['/etc/apache2/sites-enabled','/var/www/html']

WORKDIR /var/www/html

EXPOSE 80