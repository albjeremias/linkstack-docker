

`$ docker-compose exec linkstack /bin/sh`

`> $ php artisan key:generate`
`> $ php artisan migrate`




export SERVER_ADMIN="${SERVER_ADMIN:-you@example.com}"
export HTTP_SERVER_NAME="${HTTP_SERVER_NAME:-localhost}"
export HTTPS_SERVER_NAME="${HTTPS_SERVER_NAME:-localhost}"
export LOG_LEVEL="${LOG_LEVEL:-info}"
export TZ="${TZ:-UTC}"
export PHP_MEMORY_LIMIT="${PHP_MEMORY_LIMIT:-256M}"
export UPLOAD_MAX_FILESIZE="${UPLOAD_MAX_FILESIZE:-8M}"



echo '| Updating Configuration: PHP         (/etc/php83/40-custom.ini)     |'
echo "| Setting PHP Configuration:                                         |"
echo "| upload_max_filesize = ${UPLOAD_MAX_FILESIZE}                       |"
echo "| memory_limit = ${PHP_MEMORY_LIMIT}                                 |"
echo "| date.timezone = ${TZ}                                              |"

echo "upload_max_filesize = ${UPLOAD_MAX_FILESIZE}" >> /etc/php83/conf.d/40-custom.ini
echo "memory_limit = ${PHP_MEMORY_LIMIT}" >> /etc/php83/conf.d/40-custom.ini
echo "date.timezone = ${TZ}" >> /etc/php83/conf.d/40-custom.ini
