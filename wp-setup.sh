#!/bin/bash
set -e

# Configurable environment variables
DB_HOST=${WORDPRESS_DB_HOST:-db}
DB_PORT=${WORDPRESS_DB_PORT:-3306}
DB_NAME=${WORDPRESS_DB_NAME:-wordpress}
DB_USER=${WORDPRESS_DB_USER:-wp_user}
DB_PASS=${WORDPRESS_DB_PASSWORD:-wp_pass}
SITE_URL=${SITE_URL:-http://localhost:8080}
SITE_TITLE=${SITE_TITLE:-OrderBox Site}
ADMIN_USER=${ADMIN_USER:-admin}
ADMIN_PASS=${ADMIN_PASS:-password}
ADMIN_EMAIL=${ADMIN_EMAIL:-admin@example.com}

echo "Waiting for database at $DB_HOST:$DB_PORT..."
until mysql -h"$DB_HOST" \
            -P"$DB_PORT" \
            -u"$DB_USER" \
            -p"$DB_PASS" \
            --skip-ssl \
            "$DB_NAME" -e "SELECT 1;" &> /dev/null; do
  echo "Database not ready yet... sleeping 5s"
  sleep 5
done


# Install WordPress if not installed
if ! wp core is-installed --path=/var/www/html --allow-root; then
  echo "Running wp core install..."
  wp core install \
    --url="${WORDPRESS_URL:-$SITE_URL}" \
    --title="${WORDPRESS_TITLE:-OrderBox}" \
    --admin_user="${WORDPRESS_ADMIN_USER:-admin}" \
    --admin_password="${WORDPRESS_ADMIN_PASSWORD:-password}" \
    --admin_email="${WORDPRESS_ADMIN_EMAIL:-admin@example.com}" \
    --path=/var/www/html \
    --allow-root
fi

# Install plugins/themes
wp plugin install woocommerce --activate --path=/var/www/html --allow-root
wp plugin install woocommerce-gateway-stripe --activate --path=/var/www/html --allow-root
wp plugin install food-online-for-woocommerce --activate --path=/var/www/html --allow-root
wp plugin install woocommerce-payments --activate --path=/var/www/html --allow-root
wp theme install foodie-world --activate --path=/var/www/html --allow-root

# Start Apache in foreground
exec docker-entrypoint.sh apache2-foreground