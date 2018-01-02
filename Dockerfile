# Kolossus Installer
#
# To build:
# docker build -t kolossus-installer:1.8.4 .
#
# To run:
# - Set ENV variables
# - Mount /installer/platforms/aws/backend.tf.json
# - Mount /user.tfvars.json
# - Mount /output
# - Specify a command {start,resize,destroy}
#
# References:
# https://releases.tectonic.com/releases/tectonic_1.8.4-tectonic.2.zip
# https://coreos.com/tectonic/docs/latest/install/aws/aws-terraform.html

FROM debian:stable-slim

LABEL maintainer="Ben Cessa <ben@kolossus.io>"

ARG TERRAFORM_VER=0.11.1
ARG TECTONIC_INSTALLER=1.8.4-tectonic.2

COPY init.sh /init
COPY kolossus.tfvars.json /kolossus.tfvars.json

# Dependencies
RUN \
  apt update && \
  apt install -y curl jq wget unzip python-pip && \
  pip install awscli

# Terraform
RUN \
  wget https://releases.hashicorp.com/terraform/${TERRAFORM_VER}/terraform_${TERRAFORM_VER}_linux_amd64.zip && \
  unzip terraform_${TERRAFORM_VER}_linux_amd64.zip -d /usr/local/bin/ && \
  rm terraform_${TERRAFORM_VER}_linux_amd64.zip

# Tectonic Installer
RUN \
  wget https://releases.tectonic.com/releases/tectonic_${TECTONIC_INSTALLER}.zip && \
  unzip tectonic_${TECTONIC_INSTALLER}.zip && \
  mv tectonic_${TECTONIC_INSTALLER} installer && \
  rm tectonic_${TECTONIC_INSTALLER}.zip

ENV AWS_ACCESS_KEY_ID ""
ENV AWS_SECRET_ACCESS_KEY ""
ENV AWS_REGION ""

VOLUME ["/output"]

ENTRYPOINT ["/init"]
