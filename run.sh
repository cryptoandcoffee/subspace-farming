#!/bin/bash
echo "Hello, $plots plots requested to $reward_address"

echo "Checking CPU requested"
if [ -f /sys/fs/cgroup/cpu/cpu.cfs_quota_us ]; then
CPU_COUNT=$(cat /sys/fs/cgroup/cpu/cpu.cfs_quota_us)
else
CPU_COUNT=$(cat /sys/fs/cgroup/cpu.max | awk '{print $1}')
fi
CPU_COUNT=$(echo "scale=0; $CPU_COUNT/100000" | bc -l) #Convert to Cores
echo "Found $CPU_COUNT cpus available."


#Setup filemanager
mkdir /plots
chmod 777 /plots -R
cp /filemanager/tinyfilemanager.php /plots/index.php
echo "Setup filemanager done"
#Setup nginx for filemanager
mv /config.php /plots/
mv /nginx.conf /etc/nginx/sites-enabled/default
mv /nginx-default.conf /etc/nginx/nginx.conf

sed -i -e "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g" /etc/php/8.3/fpm/php.ini
sed -i -e "s/upload_max_filesize\s*=\s*2M/upload_max_filesize = 1000G/g" /etc/php/8.3/fpm/php.ini
sed -i -e "s/post_max_size\s*=\s*8M/post_max_size = 1000G/g" /etc/php/8.3/fpm/php.ini
sed -i -e "/listen\s*=\s*\/run\/php\/php8.3-fpm.sock/c\listen = 127.0.0.1:9000" /etc/php/8.3/fpm/pool.d/www.conf
sed -i -e "/pid\s*=\s*\/run/c\pid = /run/php8.3-fpm.pid" /etc/php/8.3/fpm/php-fpm.conf
#Adjusting app name
sed -i -e "s/File Manager/Subspace Plot Manager/g" /plots/index.php

/etc/init.d/nginx start
/etc/init.d/php8.3-fpm start

echo "Using $plots plots"

echo "Fetching the latest release from GitHub..."
#latest_release=$(curl -s https://api.github.com/repos/subspace/subspace/releases/latest | jq -r '.assets[] | select(.name | contains("farmer") and contains("v2") and contains("ubuntu") and contains("x86_64")) | .browser_download_url' | head -n1)
#latest_release=$(curl -s https://api.github.com/repos/subspace/subspace/releases/latest | jq -r '.assets[] | select(.name | contains("farmer") and contains("ubuntu") and contains("x86_64")) | .browser_download_url' | head -n1)

# Identify CPU model
cpu_model=$(lscpu | grep "Model name" | cut -d ':' -f2 | xargs)

echo "Detected CPU: $cpu_model"

# Determine the appropriate release based on CPU model
if [[ "$cpu_model" == *"Ryzen"* || "$cpu_model" == *"EPYC"* || "$cpu_model" == *"v4"* || "$cpu_model" == *"v5"* || "$cpu_model" == *"Icelake"* ]]; then
  echo "Fetching the latest release for Ryzen from GitHub..."
  latest_release=$(curl -s https://api.github.com/repos/subspace/subspace/releases/latest | jq -r '.assets[] | select(.name | contains("farmer") and contains("ubuntu") and contains("x86_64")) | .browser_download_url' | head -n1)
elif [[ "$cpu_model" == *"Broadwell"* || "$cpu_model" == *"Haswell"* || "$cpu_model" == *"v2"*  || "$cpu_model" == *"v3"* ]]; then
  echo "Fetching the latest V2 release for Broadwell from GitHub..."
  latest_release=$(curl -s https://api.github.com/repos/subspace/subspace/releases/latest | jq -r '.assets[] | select(.name | contains("farmer") and contains("v2") and contains("ubuntu") and contains("x86_64")) | .browser_download_url' | head -n1)
else
  echo "No specific release found for $cpu_model. Using failsafe v2"
  latest_release=$(curl -s https://api.github.com/repos/subspace/subspace/releases/latest | jq -r '.assets[] | select(.name | contains("farmer") and contains("v2") and contains("ubuntu") and contains("x86_64")) | .browser_download_url' | head -n1)
fi

if [ $? -ne 0 ]; then
  echo "Error: Failed to fetch the latest release from GitHub. Please check your internet connection and try again."
  exit
fi
echo "Latest release URL: $latest_release"

executable=$(echo $latest_release | awk -F'/' '{print $NF}')
echo "Using $executable"

echo "Downloading the latest release..."
wget $latest_release
if [ $? -ne 0 ]; then
  echo "Error: Failed to download the latest release. Please check your internet connection and try again."
  exit
fi
echo "Latest release : $latest_release downloaded successfully."

echo "Setting executable permissions on the binary..."
chmod +x $executable
echo "Executable permissions set successfully."

# Define base parameters
base_command="./${executable} farm --allow-private-ips --node-rpc-url ws://node:9944 --listen-on /ip4/0.0.0.0/udp/30533/quic-v1 --listen-on /ip4/0.0.0.0/tcp/30533 --reward-address $reward_address"
path_base="/plots/plot"

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
