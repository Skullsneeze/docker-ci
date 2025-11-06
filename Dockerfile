ARG PHP_VERSION=8.3
ARG NODE_MAJOR=20
FROM php:${PHP_VERSION}-cli-bookworm

LABEL maintainer="Martijn Swinkels"
LABEL description="Reusable CI runner image for PHP + Node projects"

# -------------------------------------------------------
# Base packages
# -------------------------------------------------------
RUN apt-get update && apt-get install -y \
      git unzip zip curl make gnupg lftp pkg-config \
      libicu-dev libpq-dev libxml2-dev libpng-dev libjpeg-dev libfreetype6-dev \
      libzip-dev libcurl4-openssl-dev libonig-dev libxslt-dev \
  && rm -rf /var/lib/apt/lists/*

# -------------------------------------------------------
# Node.js
# -------------------------------------------------------
RUN apt-get update && apt-get install -y ca-certificates curl gnupg \
 && mkdir -p /etc/apt/keyrings \
 && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key \
      | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
 && NODE_MAJOR=${NODE_MAJOR:-20} \
 && echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] \
      https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" \
      > /etc/apt/sources.list.d/nodesource.list \
 && apt-get update && apt-get install -y nodejs \
 && node --version && npm --version

# -------------------------------------------------------
# Composer
# -------------------------------------------------------
COPY --from=composer:2 /usr/bin/composer /usr/local/bin/composer
ENV PATH="$PATH:/root/.composer/vendor/bin"

# Global Composer deps (Deployer etc.)
RUN composer global require deployer/deployer:^7.3 \
 && ln -sf /root/.composer/vendor/bin/dep /usr/local/bin/dep

# -------------------------------------------------------
# PHP Extensions
# -------------------------------------------------------
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
 && docker-php-ext-configure intl \
 && docker-php-ext-configure zip \
 && docker-php-ext-install -j$(nproc) \
      bcmath \
      intl \
      gd \
      mbstring \
      pcntl \
      pdo_mysql \
      mysqli \
      pdo_pgsql \
      pgsql \
      soap \
      zip \
      xml \
      exif \
      opcache \
      posix \
      readline \
      sockets \
      pdo_sqlite \
      sqlite3 \
 && docker-php-ext-enable \
      bcmath intl gd mbstring pcntl pdo_mysql mysqli pdo_pgsql pgsql \
      soap zip xml exif opcache posix readline sockets pdo_sqlite sqlite3 \
 && pecl install apcu redis \
 && docker-php-ext-enable apcu redis \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# -------------------------------------------------------
# Node package managers
# -------------------------------------------------------
RUN corepack enable pnpm \
 && npm install -g yarn

WORKDIR /app

CMD ["php", "-v"]
