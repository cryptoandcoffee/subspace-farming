FROM ubuntu:24.04
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get dist-upgrade -yqq && \
    apt-get install -yqq --no-install-recommends \
    git sshpass rsync screen sudo nginx php-fpm lsb-release jq bc \
    libgmp3-dev build-essential cmake libboost-all-dev libnuma-dev wget curl nano \
    python3.11-venv dnsutils && \
    # Clean up to reduce image size
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN git clone https://github.com/prasathmani/tinyfilemanager filemanager

COPY config.php /
COPY nginx.conf /
COPY nginx-default.conf /
COPY run.sh /

ENV reward_address="st9V6Wmm2CP9nTWRxbQ6Fb4xUxadRTFrqGgCCTAyptjSotR4E"
ENV plots=1
ENV size=100G
ENV ramdrive=false

ENTRYPOINT ["/run.sh"]
