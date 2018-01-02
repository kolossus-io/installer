#!/bin/bash
VAR_FILES="-var-file=kolossus.tfvars.json -var-file=user.tfvars.json"

function start {
  terraform init installer/platforms/aws
  terraform plan ${VAR_FILES} installer/platforms/aws
  terraform apply -auto-approve ${VAR_FILES} installer/platforms/aws

  # Get output
  mv generated/auth/kubeconfig /output/.
  mv generated/tls /output/.
}

function resize {
  terraform init installer/platforms/aws
  terraform apply -auto-approve ${VAR_FILES} -target module.workers installer/platforms/aws
}

function destroy {
  terraform init installer/platforms/aws
  terraform destroy -force ${VAR_FILES} installer/platforms/aws
}

case "$1" in
  start)
    start
    ;;
  resize)
    resize
    ;;
  destroy)
    destroy
    ;;
esac
