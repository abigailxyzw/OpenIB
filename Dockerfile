FROM php:7.3-apache

RUN set -eux; \
	\
	apt-get update; \
	apt-get install -y --no-install-recommends \
                graphicsmagick \
                gifsicle \
                mariadb-client \
                mariadb-server \
                git \ 
                vim \
                wget \
                unzip 

#various dependencies
RUN apt-get install -y libwebp-dev \
libjpeg62-turbo-dev \
libpng-dev \
libxpm-dev \ 
libfreetype6-dev

#images
RUN docker-php-ext-configure gd \
--with-gd \
--with-webp-dir \
--with-jpeg-dir \     
--with-png-dir \
--with-zlib-dir \
--with-xpm-dir \
--with-freetype-dir     

RUN docker-php-ext-install gd

#sql calls
RUN docker-php-ext-install pdo_mysql

#caching
# Install APCu and APC backward compatibility
RUN pecl install apcu \
    && pecl install apcu_bc-1.0.3 \
    && docker-php-ext-enable apcu --ini-name 10-docker-php-ext-apcu.ini \
    && docker-php-ext-enable apc --ini-name 20-docker-php-ext-apc.ini

#
RUN apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN { \
		echo 'opcache.memory_consumption=128'; \
		echo 'opcache.interned_strings_buffer=8'; \
		echo 'opcache.max_accelerated_files=4000'; \
		echo 'opcache.revalidate_freq=60'; \
	} > /usr/local/etc/php/conf.d/opcache-recommended.ini

RUN mkdir -p /var/www/html 

COPY html /var/www/html
RUN chown -R www-data:www-data /var/www/html

COPY .git /var/www/.git

CMD ["apache2-foreground"]
