#!/bin/bash

function log() {
  echo \[$(date +%Y/%m/%d-%H:%M:%S)\] "$1"
  echo \[$(date +%Y/%m/%d-%H:%M:%S)\] "$1" >>/var/log/nebula-tools.log
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
  wget https://storage.googleapis.com/nebula-deployment-manager/v1/scripts/dashboard-install.sh
  wget https://storage.googleapis.com/nebula-deployment-manager/v1/scripts/explorer-install.sh
  wget https://storage.googleapis.com/nebula-deployment-manager/v1/scripts/nebula-download
  # runtime-config-post-result.sh used for post result to GCP, success| failure
  wget https://storage.googleapis.com/nebula-deployment-manager/v1/scripts/runtime-config-post-result.sh

  # change files format to unix
  apt update -y
  apt install dos2unix -y
  dos2unix ./*.sh

  # add execute permission
  chmod +x ./*.sh nebula-download
}

function main() {
  # Download install tools
  log "Download install tools"
  download_install_tools

  readonly enable_dasshboard="$(get_attribute_value "ENABLE_DASHBOARD")"
  log "EnableDashboard: ${enable_dasshboard}"

  readonly enable_explorer="$(get_attribute_value "ENABLE_EXPLORER")"
  log "EnableExplorer: ${enable_explorer}"

  if [[ $enable_dasshboard == true ]]; then
    # Exec nebula dashboard install scripts
    log "Exec nebula dashboard install script"
    ./dashboard-install.sh

    EXIT_CODE=$?
    if [[ $EXIT_CODE -ne 0 ]]; then
      log "Exec dashboard install script failed"
      bash runtime-config-post-result.sh failure
      exit $EXIT_CODE
    fi
  fi

  if [[ $enable_explorer == true ]]; then
    # Exec nebula explorer install scripts
    log "Exec nebula explorer install script"
    ./explorer-install.sh

    EXIT_CODE=$?
    if [[ $EXIT_CODE -ne 0 ]]; then
      log "Exec explorer install script failed"
      bash runtime-config-post-result.sh failure
      exit $EXIT_CODE
    fi
  fi

  # Post result to GCP
  bash runtime-config-post-result.sh success
  log "Install Nebula Tools successfully"
}

main
