ARG PHP_VERSION=8.3

FROM php:${PHP_VERSION}-bookworm

LABEL maintainer="Martijn Swinkels"
LABEL description="Reusable CI runner image for PHP + Node projects"

# System dependencies
RUN set -eux; \
    apt-get update && apt-get install -y \
      git unzip zip curl make gnupg lftp pkg-config openssh-client \
      libicu-dev libpq-dev libxml2-dev libpng-dev libjpeg-dev libfreetype6-dev \
      libzip-dev libcurl4-openssl-dev libonig-dev libxslt-dev rsync \
  && rm -rf /var/lib/apt/lists/*

# Node.js
ARG NODE_MAJOR=20
RUN set -eux; \
    apt-get update && apt-get install -y xz-utils ca-certificates curl; \
    ARCH=$(uname -m); \
    case "$ARCH" in \
      x86_64) ARCH_NAME="x64" ;; \
      aarch64) ARCH_NAME="arm64" ;; \
      *) echo "Unsupported arch: $ARCH" && exit 1 ;; \
    esac; \
    if [ "$NODE_MAJOR" = "14" ]; then \
        echo "Installing Node.js v14 ($ARCH_NAME) from tarball"; \
        curl -fsSL "https://nodejs.org/dist/latest-v14.x/node-v14.21.3-linux-${ARCH_NAME}.tar.xz" -o /tmp/node.tar.xz; \
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
