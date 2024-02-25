#Setup filemanager
mkdir /plots
chmod 777 /plots -R
cp /filemanager/tinyfilemanager.php /plots/index.php

#Setup nginx for filemanager
mv /config.php /plots/
mv /nginx.conf /etc/nginx/sites-enabled/default
mv /nginx-default.conf /etc/nginx/nginx.conf

sed -i -e "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g" /etc/php/8.1/fpm/php.ini
sed -i -e "s/upload_max_filesize\s*=\s*2M/upload_max_filesize = 1000G/g" /etc/php/8.1/fpm/php.ini
sed -i -e "s/post_max_size\s*=\s*8M/post_max_size = 1000G/g" /etc/php/8.1/fpm/php.ini
sed -i -e "/listen\s*=\s*\/run\/php\/php8.1-fpm.sock/c\listen = 127.0.0.1:9000" /etc/php/8.1/fpm/pool.d/www.conf
sed -i -e "/pid\s*=\s*\/run/c\pid = /run/php8.1-fpm.pid" /etc/php/8.1/fpm/php-fpm.conf
#Adjusting app name
sed -i -e "s/File Manager/Chia Plot Manager/g" /plots/index.php
sed -i -e "s/Tiny Chia Plot Manager/Chia Plot Manager/g" /plots/index.php

/etc/init.d/nginx start
/etc/init.d/php8.1-fpm start

mkdir -p /root/chia/final
mkdir -p /root/chia/tmp2
mkdir -p /root/chia/tmp
