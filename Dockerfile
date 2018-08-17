# Kolossus Installer
#
# References:
# https://coreos.com/tectonic/docs/latest/install/aws/aws-terraform.html

FROM debian:stable-slim

ARG VERSION_TAG=0.2.0
ARG TERRAFORM_VER=0.11.8
ARG TECTONIC_INSTALLER

LABEL maintainer="Ben Cessa <ben@kolossus.io>"
LABEL version=${VERSION_TAG}

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

ENV VERSION_TAG ${VERSION_TAG}
ENV TERRAFORM_VER ${TERRAFORM_VER}
ENV TECTONIC_INSTALLER ${TECTONIC_INSTALLER}
ENV AWS_ACCESS_KEY_ID ""
ENV AWS_SECRET_ACCESS_KEY ""
ENV AWS_REGION ""

VOLUME ["/output"]

ENTRYPOINT ["/init"]
