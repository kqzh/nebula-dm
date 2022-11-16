#!/bin/bash

function log() {
  echo \[$(date +%Y/%m/%d-%H:%M:%S)\] "$1"
  echo \[$(date +%Y/%m/%d-%H:%M:%S)\] "$1" >>/var/log/graph-install.log
}

function get_metadata_value() {
  curl --retry 5 \
    -s \
    -f \
    -H "Metadata-Flavor: Google" \
    "http://metadata.google.internal/computeMetadata/v1/$1"
}

function get_attribute_value() {
  get_metadata_value "instance/attributes/$1"
}

function download_install_tools() {
  # nebula-install.sh used for install nebula
  wget https://storage.googleapis.com/nebula-deployment-manager/v1/scripts/nebula-install.sh
  # nebula-download used for download ent nebula、 dashboard、 explorer pkg
  wget https://storage.googleapis.com/nebula-deployment-manager/v1/scripts/nebula-download
  # vm-disk-utils.sh used for set vm disk
  wget https://storage.googleapis.com/nebula-deployment-manager/v1/scripts/vm-disk-utils.sh
  # runtime-config-post-result.sh used for post result to GCP, success| failure
  wget https://storage.googleapis.com/nebula-deployment-manager/v1/scripts/runtime-config-post-result.sh

  # change files format to unix
  apt update -y
  apt install dos2unix -y
  dos2unix ./*.sh

  # add execute permission
  chmod +x nebula-install.sh nebula-download vm-disk-utils.sh runtime-config-post-result.sh
}

function main() {
  # Get the list of Metad nodes
  readonly meta_server_address="$(get_attribute_value "META_SERVER_ADDRESS")"
  log "MetadAddress: ${meta_server_address}"

  # Download install tools
  log "Download install tools"
  download_install_tools

  # Exec nebula install scripts
  log "Exec nebula-install script"
  ./nebula-install.sh -c graphd -m $meta_server_address

  # Post result to GCP
  EXIT_CODE=$?
  if [[ $EXIT_CODE -ne 0 ]]; then
    log "Exec nebula install script failed"
    ./runtime-config-post-result.sh failure
    exit $EXIT_CODE
  fi

  ./runtime-config-post-result.sh success
  log "Install Graphd successfully"
}

main
