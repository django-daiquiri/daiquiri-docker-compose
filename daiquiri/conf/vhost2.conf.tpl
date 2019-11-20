<VirtualHost *:9494>

    RewriteEngine On
    RewriteRule ^/(.*) http://172.19.0.5:80/$1
    ProxyPassReverse / http://localhost:80/

</VirtualHost>
