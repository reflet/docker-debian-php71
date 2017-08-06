FROM php:7.1-fpm

# system update
RUN apt-get -y update && apt-get -y upgrade

# locale
RUN apt-get -y install locales && \
    localedef -f UTF-8 -i ja_JP ja_JP.UTF-8
ENV LANG ja_JP.UTF-8
ENV LANGUAGE ja_JP:ja
ENV LC_ALL ja_JP.UTF-8

# timezone (Asia/Tokyo)
ENV TZ JST-9

# etc
ENV TERM xterm

# tools
RUN apt-get install -y vim git zip unzip less wget

# Libraries
RUN echo "Installing Libraries" \
    && apt-get install -y \
       libfreetype6-dev \
       libgd-dev \
       libgmp-dev \
       libmcrypt-dev \
       libbz2-dev \
       libxml2-dev \
       libxslt1-dev \
       libgettextpo-dev \
       libcurl4-openssl-dev \
       libc-client-dev libkrb5-dev \       
       libsqlite3-dev \
       libedit-dev \
       libpq-dev \
    && apt install -y \
       libtidy-dev

# php options(gd, exif)
RUN echo "Installing PHP extensions(gd, exif)" \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install gd exif

# php options(gmp)
RUN echo "Installing PHP extensions(gmp)" \
    && ln -s /usr/include/x86_64-linux-gnu/gmp.h /usr/include/ \
    && docker-php-ext-install gmp

# php options(imap)
RUN echo "Installing PHP extensions(imap)" \
    && docker-php-ext-configure imap --with-kerberos --with-imap-ssl

# php options
#
# - allredy installed -
# session mbstring json pdo tokenizer ctype fileinfo iconv curl dom simplexml xml xmlwriter
# pdo_sqlite posix readline ftp phar
#
RUN echo "Installing PHP extensions" \
    && docker-php-ext-install \
       mysqli pdo_mysql pdo_pgsql pgsql dba mcrypt zip bz2 soap sockets xsl \
       bcmath calendar pcntl wddx gettext opcache tidy

# php options (Memcached)
RUN apt-get install -y libmemcached-dev && \
pecl install memcached && \
docker-php-ext-enable memcached

# php options (ssmtp)
RUN apt-get install -y ssmtp mailutils

# cleanup
RUN apt-get -y autoremove \
    && apt-get clean all \
    && rm -rf /var/www/html/

# composer
RUN curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer

# user setting
WORKDIR /var/www/
RUN usermod -u 500 www-data \
    && groupmod -g 500 www-data
