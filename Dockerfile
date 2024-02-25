FROM ubuntu:22.04
RUN apt-get update ; apt-get dist-upgrade -y rsync git 
RUN git clone https://github.com/prasathmani/tinyfilemanager filemanager
COPY run.sh /
ENTRYPOINT ["/run.sh"]
