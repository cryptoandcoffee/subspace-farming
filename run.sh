#!/bin/bash
echo "Hello, $plots plots requested"
#Setup filemanager
mkdir /plots
chmod 777 /plots -R
cp /filemanager/tinyfilemanager.php /plots/index.php
echo "Setup filemanager done"
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
sed -i -e "s/File Manager/Subspace Plot Manager/g" /plots/index.php
sed -i -e "s/Tiny Chia Plot Manager/Subspace Plot Manager/g" /plots/index.php

/etc/init.d/nginx start
/etc/init.d/php8.1-fpm start

#mkdir -p /root/chia/final
#mkdir -p /root/chia/tmp2
#mkdir -p /root/chia/tmp

#./subspace-farmer-ubuntu-x86_64-v2-gemini-3h-2024-feb-19 farm --farm-during-initial-plotting=true --node-rpc-url ws://node:9944 --listen-on /ip4/0.0.0.0/udp/30533/quic-v1 --listen-on /ip4/0.0.0.0/tcp/30533 --reward-address $reward_address path=/plots,size=100G

if [[ $ramdrive == "true" ]]; then
  mkdir -p "${dir_path}"
  mount -t tmpfs -o size=110G tmpfs "${dir_path}"
fi


echo "Using $plots plots"

# Define base parameters
base_command="./subspace-farmer-ubuntu-x86_64-v2-gemini-3h-2024-feb-19 farm --farm-during-initial-plotting=true --node-rpc-url ws://node:9944 --listen-on /ip4/0.0.0.0/udp/30533/quic-v1 --listen-on /ip4/0.0.0.0/tcp/30533 --reward-address \$reward_address"
path_base="/plots/plot"
#size="100G"

# Create directories for each plot
for (( i=1; i<=plots; i++ ))
do
    dir_path="${base_dir}${i}"
    echo "Creating directory: ${dir_path}"
    mkdir -p "${dir_path}"
    if [[ $ramdrive == "true" ]]; then
      mount -t tmpfs -o size=$size tmpfs "${dir_path}"
    fi
done



echo "All directories created."

# Loop to generate and run commands for each plot
for (( i=1; i<=plots; i++ ))
do
    path="${path_base}${i},size=${size}"
    command="${base_command} path=${path}"
    echo "Executing: ${command}"
    eval $command &
done

wait # Wait for all background jobs to finish
echo "All plotting commands executed."
