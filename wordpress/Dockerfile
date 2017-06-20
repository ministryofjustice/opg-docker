FROM registry.service.opg.digital/opguk/php-fpm

RUN apt-get update && apt-get install -y php5-mysql php5-curl libpng12-dev libjpeg-dev && \
    apt-get clean && apt-get autoremove && \
    rm -rf /var/lib/cache/* /var/lib/log/* /tmp/* /var/tmp/* && \
    mkdir -p /data && \
    chown app:app /data

USER app

# Install wordpress
RUN cd /tmp && \
    wget --no-verbose https://en-gb.wordpress.org/latest-en_GB.tar.gz && \
    tar -xf latest-en_GB.tar.gz && \
    rm -rf wordpress/wp-content/themes/* && \
    rm -rf wordpress/wp-content/plugins/hello.php wordpress/wp-content/plugins/akismet && \
    mv wordpress/* /data/. && \
    rm -rf wordpress latest-en_GB.tar.gz

# Install lastest versions of required plugins
ENV WP_PLUGIN_DL="https://downloads.wordpress.org/plugin"
RUN cd /tmp && \
    wget --no-verbose ${WP_PLUGIN_DL}/yet-another-related-posts-plugin.4.4.zip && \
    wget --no-verbose ${WP_PLUGIN_DL}/wordpress-popular-posts.3.3.4.zip && \
    wget --no-verbose ${WP_PLUGIN_DL}/updraftplus.1.13.4.zip && \
    wget --no-verbose ${WP_PLUGIN_DL}/cms-tree-page-view.1.3.4.zip && \
    wget --no-verbose ${WP_PLUGIN_DL}/google-analytics-dashboard-for-wp.5.0.1.zip && \
    wget --no-verbose ${WP_PLUGIN_DL}/google-sitemap-generator.4.0.8.zip && \
    wget --no-verbose ${WP_PLUGIN_DL}/tablepress.1.8.zip && \
    wget --no-verbose ${WP_PLUGIN_DL}/user-role-editor.4.35.zip && \
    unzip -q \*.zip && \
    rm *.zip && \
    find . -maxdepth 1 -type d -not -path "." -exec mv '{}' /data/wp-content/plugins \;

# Install "custom" wordpress plugins and our theme
COPY docker/wp-content /data/wp-content

# Install our custom theme
# Add wordpress configuration templates
ADD docker/confd /etc/confd

USER root

# Remove files included from php-fpm container
RUN rm -rf /app/* && \
    ln -s /data /app/public

ADD  docker/my_init.d /etc/my_init.d
RUN  chmod a+x /etc/my_init.d/*

ENV OPG_SERVICE wordpress
