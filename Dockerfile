ARG PHP_VERSION=8.3

FROM php:${PHP_VERSION}-bookworm

LABEL maintainer="Martijn Swinkels"
LABEL description="Reusable CI runner image for PHP + Node projects"

# System dependencies
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        git curl unzip make lftp gnupg ca-certificates \
        build-essential pkg-config; \
    rm -rf /var/lib/apt/lists/*

# Node.js
ARG NODE_MAJOR=20
RUN set -eux; \
    apt-get update && apt-get install -y xz-utils ca-certificates curl; \
    if [ "$NODE_MAJOR" = "14" ]; then \
        echo "Installing Node.js v14 from tarball"; \
        curl -fsSL "https://nodejs.org/dist/latest-v14.x/node-v14.21.3-linux-x64.tar.xz" -o /tmp/node.tar.xz; \
        tar -xJf /tmp/node.tar.xz -C /usr/local --strip-components=1 --no-same-owner; \
        rm /tmp/node.tar.xz; \
    else \
        echo "Installing Node.js v$NODE_MAJOR from NodeSource"; \
        mkdir -p /etc/apt/keyrings; \
        curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key \
          | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg; \
        echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] \
          https://deb.nodesource.com/node_${NODE_MAJOR}.x nodistro main" \
          > /etc/apt/sources.list.d/nodesource.list; \
        apt-get update && apt-get install -y nodejs; \
    fi; \
    node --version && npm --version; \
    rm -rf /var/lib/apt/lists/*

# Composer & Deployer
COPY --from=composer:2 /usr/bin/composer /usr/local/bin/composer
ENV PATH="$PATH:/root/.composer/vendor/bin"

RUN composer global require deployer/deployer:^7.3 \
 && ln -sf /root/.composer/vendor/bin/dep /usr/local/bin/dep

# PHP extensions (via mlocati/php-extension-installer)
COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/local/bin/

RUN install-php-extensions \
      bcmath \
      gd \
      intl \
      mbstring \
      zip \
      pdo_mysql \
      mysqli \
      pdo_pgsql \
      pgsql \
      sockets \
      sqlite3 \
      exif

# Node package managers
RUN corepack enable pnpm \
 && npm install -g yarn

WORKDIR /app
CMD ["php", "-v"]
