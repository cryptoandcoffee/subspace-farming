FROM ubuntu:22.04
#RUN apt-get update ; apt-get dist-upgrade -y rsync git wget nginx php8.0
RUN apt-get update ; DEBIAN_FRONTEND=noninteractive apt-get dist-upgrade -yqq ; DEBIAN_FRONTEND=noninteractive apt-get install -yqq git sshpass rsync screen sudo nginx php-fpm lsb-release jq bc libgmp3-dev build-essential cmake libboost-all-dev libnuma-dev wget curl nano python3.11-venv dnsutils
RUN git clone https://github.com/prasathmani/tinyfilemanager filemanager
RUN wget https://github.com/subspace/subspace/releases/download/gemini-3h-2024-mar-18/subspace-farmer-ubuntu-x86_64-v2-gemini-3h-2024-mar-18
RUN chmod +x subspace-farmer-ubuntu-x86_64-v2-gemini-3h-2024-mar-18
#RUN mv subspace-farmer-ubuntu-x86_64-v2-gemini-3h-2024-feb-19 farm
COPY config.php /
COPY nginx.conf /
COPY nginx-default.conf /
COPY run.sh /

ENV reward_address="st9V6Wmm2CP9nTWRxbQ6Fb4xUxadRTFrqGgCCTAyptjSotR4E"
ENV plots=1
ENV size=100G
ENV ramdrive=false

ENTRYPOINT ["/run.sh"]
