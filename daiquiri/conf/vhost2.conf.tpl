<VirtualHost *:9494>

    ErrorDocument 200 "ok"

    RewriteEngine On
    RewriteRule ^/(.*) http://127.0.0.1:80/$1 [R=200]

</VirtualHost>
