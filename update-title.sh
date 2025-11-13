#!/bin/sh
# This script updates the TAO title after installation

echo "Updating TAO title to 'Sharda Informatics Testing Platform'..."

# Update layout templates
find /var/www/html -type f -name "*.tpl" 2>/dev/null | while read file; do
    sed -i 's/<title>TAO<\/title>/<title>Sharda Informatics Testing Platform<\/title>/g' "$file" 2>/dev/null || true
    sed -i 's/{{__ "TAO"}}/Sharda Informatics Testing Platform/g' "$file" 2>/dev/null || true
done

# Update JavaScript files
find /var/www/html -type f -name "*.js" 2>/dev/null | while read file; do
    sed -i "s/document.title = 'TAO'/document.title = 'Sharda Informatics Testing Platform'/g" "$file" 2>/dev/null || true
done

echo "Title update complete!"
