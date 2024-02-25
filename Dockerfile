FROM ubuntu:22.04
RUN apt-get update ; apt-get dist-upgrade -y rsync git 
RUN git clone https://github.com/prasathmani/tinyfilemanager filemanager
RUN wget https://github.com/subspace/subspace/releases/download/gemini-3h-2024-feb-19/subspace-farmer-ubuntu-x86_64-v2-gemini-3h-2024-feb-19
RUN mv subspace-farmer-ubuntu-x86_64-v2-gemini-3h-2024-feb-19 farmer
COPY run.sh /
ENTRYPOINT ["/run.sh"]
