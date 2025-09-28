# Base image
FROM wordpress:php8.3-apache

# Install extra dependencies for plugins if needed
RUN apt-get update && apt-get install -y \
    unzip \
    git \
    curl \
    default-mysql-client \
    && rm -rf /var/lib/apt/lists/*

# Copy custom plugins and themes
COPY wp-content/plugins /var/www/html/wp-content/plugins
COPY wp-content/themes /var/www/html/wp-content/themes

# Set permissions
RUN chown -R www-data:www-data /var/www/html/wp-content

# Install WP-CLI
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

# Copy setup script
COPY wp-setup.sh /usr/local/bin/wp-setup.sh
RUN chmod +x /usr/local/bin/wp-setup.sh

# Use the setup script as entrypoint
ENTRYPOINT ["/usr/local/bin/wp-setup.sh"]
CMD ["apache2-foreground"]