ARG PHP_VERSION=8.3
ARG NODE_MAJOR=20
FROM php:${PHP_VERSION}-cli-bookworm

LABEL maintainer="Martijn Swinkels"
LABEL description="Reusable CI runner image for PHP + Node projects"

RUN apt-get update && apt-get install -y \
    git unzip zip curl make gnupg lftp \
    && rm -rf /var/lib/apt/lists/*

# Node
RUN apt-get update && apt-get install -y ca-certificates curl gnupg \
 && mkdir -p /etc/apt/keyrings \
 && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
 && NODE_MAJOR=${NODE_MAJOR:-20} \
 && echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" > /etc/apt/sources.list.d/nodesource.list \
 && apt-get update && apt-get install -y nodejs \
 && node --version && npm --version


# Composer
COPY --from=composer:2 /usr/bin/composer /usr/local/bin/composer
ENV PATH="$PATH:/root/.composer/vendor/bin"

# Global Composer deps
RUN composer global require deployer/deployer:^7.3 \
 && ln -sf /root/.composer/vendor/bin/dep /usr/local/bin/dep

# PHP zip extension
RUN apt-get update && apt-get install -y \
      libzip-dev \
      libpng-dev \
      libjpeg-dev \
      libfreetype6-dev \
      pkg-config \
 && docker-php-ext-configure zip \
 && docker-php-ext-install zip \
 && docker-php-ext-enable zip

# Enable PNPM and install Yarn globally
RUN corepack enable pnpm \
 && npm install -g yarn

WORKDIR /app

