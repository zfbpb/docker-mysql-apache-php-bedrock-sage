# FROM php:8.0-cli
FROM php:${PHP_VERSION:+${PHP_VERSION}-}cli

LABEL name=utility-service

ARG USER_ID=1000
ARG GROUP_ID=1000

# Instalirajte potrebne pakete
RUN apt-get update && apt-get install -y \
  sudo \
  && rm -rf /var/lib/apt/lists/*

# Add user & group
RUN groupadd -g $GROUP_ID bedrock \
  && useradd -m -u $USER_ID -g bedrock bedrock

# Install tools and clean up unnecessary packages/files afterwards
RUN apt-get update && apt-get install -y \
  git \
  zip \
  unzip \
  curl \
  default-mysql-client \
  vim \
  nano \
  wget \
  # WP-CLI installation
  && curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
  && chmod +x wp-cli.phar \
  && mv wp-cli.phar /usr/local/bin/wp \
  # Node.js installation
  && curl -sL https://deb.nodesource.com/setup_14.x | bash - \
  && apt-get install -y nodejs \
  # Yarn installation
  && curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
  && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
  && apt-get update && apt-get install -y yarn \
  # nvm installation
  && curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash \
  # Composer installation
  && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
  # Cleanup
  && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
  && rm -rf /var/lib/apt/lists/* \
  && apt-get clean

WORKDIR /var/www/html

COPY ./build/.env /usr/local/bin/.env

COPY  ./docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

USER bedrock

CMD ["/usr/local/bin/docker-entrypoint.sh"]
