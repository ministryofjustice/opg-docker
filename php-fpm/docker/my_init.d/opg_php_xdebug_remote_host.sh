#!/bin/sh

rm -f /etc/php5/fpm/conf.d/*xdebug*
rm -f /etc/php5/cli/conf.d/*xdebug*


if [ -n "${OPG_PHP_XDEBUG_REMOTE_HOST}" ]
then
    echo "Enabling PHP XDEBUG"
    cp /etc/php5/xdebug-enable.ini /etc/php5/fpm/conf.d/20-xdebug.ini
    echo "xdebug.remote_host=${OPG_PHP_XDEBUG_REMOTE_HOST}" >> /etc/php5/fpm/conf.d/20-xdebug.ini
    cp /etc/php5/xdebug-enable.ini /etc/php5/cli/conf.d/20-xdebug.ini
    echo "xdebug.remote_host=${OPG_PHP_XDEBUG_REMOTE_HOST}" >> /etc/php5/cli/conf.d/20-xdebug.ini
else
    echo "Disabling PHP XDEBUG - OPG_PHP_XDEBUG_REMOTE_HOST is not configured"
    cp /etc/php5/xdebug-disable.ini /etc/php5/fpm/conf.d/20-xdebug.ini
    cp /etc/php5/xdebug-disable.ini /etc/php5/cli/conf.d/20-xdebug.ini
    rm /etc/php5/mods-available/xdebug.ini
fi
