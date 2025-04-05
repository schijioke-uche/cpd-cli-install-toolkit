#!/usr/bin/env bash

#---------------------------------------------------------------------------------------------------------------------
#                                 CLOUD PAK FOR DATA CLI INSTALLATION
#---------------------------------------------------------------------------------------------------------------------
# @Author: Dr. Jeffrey Chijioke-Uche
# @Usage:  Install cpd-cli

#################################################
# Permissions & Sourcing
#################################################
chmod 777 license_accept.sh
chmod 777 vars.sh

# Use "." instead of "source" for broader shell compatibility if needed
. ./license_accept.sh
. ./vars.sh

#################################################
# Progress Advisor
#################################################
progress_bar() {
    local duration=$1
    local bar_length=40
    local spin_chars=('🔄' '🔃' '🔁' '🔂')
    local spin_index=0

    echo -ne "["
    for ((i = 0; i < bar_length; i++)); do echo -ne "⚪"; done
    echo -ne "]\r["

    start_time=$(date +%s)
    while true; do
        elapsed=$(( $(date +%s) - start_time ))
        progress=$(( (elapsed * bar_length) / duration ))

        spin_char="${spin_chars[spin_index]}"
        spin_index=$(( (spin_index + 1) % 4 ))

        echo -ne "\r["
        for ((i = 0; i < progress; i++)); do echo -ne "🟢"; done
        for ((i = progress; i < bar_length; i++)); do echo -ne "🔵"; done
        echo -ne "] $spin_char"

        if [ $elapsed -ge $duration ]; then
            break
        fi
        sleep 0.1
    done

    echo -e "\n✅ Progress Completed! - 100%"
    YEAR=$(date +'%Y')
}

#################################################
# install cpd cli
#################################################
install_cpd_cli() {
  CPD_CLI_VERSION="14.1.1"
  OS_ARCHITECTURE="linux-SE"  # Options: linux, darwin, s390x, etc.
  URL="https://github.com/IBM/cpd-cli/releases/download/v${CPD_CLI_VERSION}/cpd-cli-${OS_ARCHITECTURE}-${CPD_CLI_VERSION}.tgz"
  FILENAME="cpd-cli-${OS_ARCHITECTURE}-${CPD_CLI_VERSION}.tgz"
  EXTRACT_DIR="cpd-cli-${OS_ARCHITECTURE}-${CPD_CLI_VERSION}"
  INSTALL_DIR="/usr/local/bin"

  echo "📥 Downloading cpd-cli version ${CPD_CLI_VERSION}..."
  curl -L -o "$FILENAME" "$URL"

  if [ $? -ne 0 ]; then
    echo "❌ Error downloading cpd-cli. Exiting."
    return 1
  fi

  echo "📦 Extracting cpd-cli..."
  tar -xzf "$FILENAME"

  echo "🔧 Installing cpd-cli..."
  cd "$EXTRACT_DIR"
  sudo mv cpd-cli "$INSTALL_DIR"
  sudo mv plugins "$INSTALL_DIR"
  sudo mv LICENSES "$INSTALL_DIR"
  sudo chmod +x "$INSTALL_DIR/cpd-cli"

  echo "🧹 Cleaning up..."
  cd ..
  rm "$FILENAME"
  rm -rf "$EXTRACT_DIR"

  echo "✅ Verifying installation..."
  cpd-cli --help

  echo "✅ cpd-cli version ${CPD_CLI_VERSION} installed successfully."
  release_version
}

#################################################
# cpd-cli check
#################################################
cpd_cli_check() {
  if command -v cpd-cli &> /dev/null; then
    progress_bar 5
    echo "✅ cpd-cli is already installed. Skipping installation."
    cpd-cli version
    release_version
    exit 0
  else
    echo "❌ cpd-cli not installed, proceeding with installation..."
    progress_bar 5
    install_cpd_cli
  fi
}


# Always last three version advise
cli_ise_advise(){
cpd_output=$(cpd-cli version 2>/dev/null)
cpd_cli_version=$(echo "$cpd_output" | grep -i "Version:" | head -n 1 | awk -F': ' '{print $2}')
cpd_release_version=$(echo "$cpd_output" | grep -i "CPD Release Version" | awk -F': ' '{print $2}')
cpd_cli_major_minor=$(echo "$cpd_cli_version" | cut -d. -f1-2)
cpd_release_major_minor=$(echo "$cpd_release_version" | cut -d. -f1-2)
case "${cpd_cli_major_minor}_${cpd_release_major_minor}" in
  "14.1_5.1")
    echo "✅ Remember: Use cpd-cli Version 14.1.x with Cloud Pak for Data Version 5.1.x"
    ;;
  "13.1_4.8")
    echo "✅ Remember: Use cpd-cli Version 13.1.x with Cloud Pak for Data Version 4.8.x"
    ;;
  "14.0_5.0")
    echo "✅ Remember: Use cpd-cli Version 14.0.x with Cloud Pak for Data Version 5.0.x"
    ;;
  *)
    echo "⚠️ No recommendation found for cpd-cli $cpd_cli_version and CPD $cpd_release_version"
    ;;
esac
}


release_version(){
cpd_version_output=$(cpd-cli version 2>/dev/null)
cpd_release_version=$(echo "$cpd_version_output" | grep "CPD Release Version" | awk -F': ' '{print $2}')
if [[ -n "$cpd_release_version" ]]; then
  echo "✅ This cli is best for cloud pak for data version: $cpd_release_version"
  cli_ise_advise
else
  echo "❌ Unable to determine Cloud Pak for Data Version."
fi
}

#################################################
# Main:
#################################################
cpd_cli_check

