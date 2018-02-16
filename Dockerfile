FROM debian:stable
ARG UNIX_USER=lamachine
ARG LAMACHINE_PATH=/lamachine
ARG DATA_PATH=/data
ARG LM_NAME=docker
ARG ANSIBLE_OPTIONS="-vv"
EXPOSE 80
USER root
MAINTAINER Maarten van Gompel <proycon@anaproy.nl>
LABEL Description="A distribution containing NLP software developed by the Language Machines Research Group and the Centre of Language and Speech Technology (both Radboud University Nijmegen) and the Tilburg Centre for Cognition and Communication (Tilburg University)"
VOLUME $DATA_PATH
RUN apt-get update
RUN apt-get install -m -y python python-pip
RUN pip install ansible
RUN useradd -ms /bin/bash $UNIX_USER
RUN echo "$UNIX_USER:lamachine" | chpasswd
RUN adduser $UNIX_USER sudo
RUN echo "$UNIX_USER ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
RUN mkdir $LAMACHINE_PATH
COPY . $LAMACHINE_PATH
COPY host_vars/lamachine-$LM_NAME.yml $LAMACHINE_PATH/host_vars/localhost.yml
RUN chown -R $UNIX_USER $LAMACHINE_PATH
USER $UNIX_USER
RUN ansible-playbook $ANSIBLE_OPTIONS $LAMACHINE_PATH/install-$LM_NAME.yml -c local
CMD /bin/bash
