#!/bin/sh

# Wait for TAO files to be available
sleep 5

# Update page titles in template files
find /var/www/html -type f \( -name "*.tpl" -o -name "*.php" \) -exec sed -i \
    -e 's/<title>TAO<\/title>/<title>Sharda Informatics Testing Platform<\/title>/g' \
    -e 's/<title>{{__ "TAO"}}<\/title>/<title>Sharda Informatics Testing Platform<\/title>/g' \
    -e "s/'TAO'/'Sharda Informatics Testing Platform'/g" \
    {} \; 2>/dev/null || true

# Update manifest files
find /var/www/html -type f -name "manifest.php" -exec sed -i \
    -e "s/'name' => 'TAO'/'name' => 'Sharda Informatics Testing Platform'/g" \
    {} \; 2>/dev/null || true

echo "Custom title applied!"
