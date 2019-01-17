#use latest armv7hf compatible raspbian OS version from group resin.io as base image
FROM balenalib/armv7hf-debian:stretch

#enable building ARM container on x86 machinery on the web (comment out next line if built on Raspberry)
RUN [ "cross-build-start" ]

#labeling
LABEL maintainer="netpi@hilscher.com" \
      version="V1.0.0" \
      description="Google Cloud SDK"

#version
ENV HILSCHERNETPI_GOOGLE_CLOUD_SDK_PYTHON 1.0.0

#copy files
COPY "./init.d/*" /etc/init.d/

RUN apt-get update \
    && apt-get install -y openssh-server \
    && echo 'root:root' | chpasswd \
    && sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config \
    && sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd \
    && mkdir /var/run/sshd \
    && apt-get install apt-transport-https lsb-release build-essential libssl-dev libffi-dev python-dev python-pip git nano wget

#install Cloud SDK (gcloud command)
RUN export CLOUD_SDK_REPO="cloud-sdk-$(lsb_release -c -s)" \
    && echo "deb http://packages.cloud.google.com/apt $CLOUD_SDK_REPO main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list \
    && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add - \
    && apt-get update \
    && apt-get install google-cloud-sdk

#install additional Python tools
RUN pip install --upgrade pip==9.0.3 \
    && pip install --upgrade setuptools \
    && pip install pyjwt paho-mqtt cryptography \
    && pip install --upgrade google-api-python-client \
    && pip install --upgrade google-cloud-core \
    && pip install --upgrade google-cloud-pubsub \
    && pip install --upgrade google-auth-httplib2 google-auth oauth2client

#install example Python application
RUN git clone https://github.com/GoogleCloudPlatform/python-docs-samples.git \
    && cd /python-docs-samples/iot/api-client/mqtt_example \
    && pip install -r requirements.txt

# change default shell folder after login
RUN echo "cd /python-docs-samples/iot/api-client/mqtt_example" >> /root/.bashrc
WORKDIR /python-docs-samples/iot/api-client/mqtt_example

# get Google root CA certificate
RUN wget https://pki.goog/roots.pem


#remove package lists
RUN rm -rf /var/lib/apt/lists/*

#set the entrypoint
ENTRYPOINT ["/etc/init.d/entrypoint.sh"]

#SSH port
EXPOSE 22

#set STOPSGINAL
STOPSIGNAL SIGTERM

#stop processing ARM emulation (comment out next line if built on Raspberry)
RUN [ "cross-build-end" ]
