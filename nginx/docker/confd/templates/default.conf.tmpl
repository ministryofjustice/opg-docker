server {
    listen     80 default_server;
    #Using global cert let's also listen on 443
    listen     443 default_server ssl;
    server_name _;
    return      444;
    access_log  /var/log/app/nginx.access.json logstash_json;
    error_log   /var/log/app/nginx.error.log error;

}

{{ if exists "/opg/nginx/host/ip" }}
server {
    #Using global cert let's also listen on 443
    listen     443 ssl;
    server_name {{ getv "/opg/nginx/host/ip" }};
    return      444;
    access_log  /var/log/app/nginx.access.json logstash_json;
    error_log   /var/log/app/nginx.error.log error;

}
{{ end }}
