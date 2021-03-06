#!/bin/bash

set -e

GREEN='\033[0;32m'
YELLOw='\033[1;33m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

hostname="rover"
wifi_ssid=""
wifi_pass=""
wifi_country="US"

main() {
  ask_for_inputs
  update_everything
  install_apps
  set_configurations
  success "Complete"
}

ask_for_inputs() {
  ask "Hostname?"
  read hostname

  ask "WiFi SSID?"
  read wifi_ssid

  ask "WiFi Password?"
  read wifi_pass

  ask "WiFi Country? (US)"
  read wifi_country
}

set_configurations() {
  info "Expanding file system"
  out=$(sudo raspi-config nonint do_expand_rootfs)
  
  info "Setting hostname"
  out=$(sudo raspi-config nonint do_hostname $hostname)
  
  info "Setting WiFi country"
  out=$(sudo raspi-config nonint do_wifi_country $wifi_country)
  
  info "Setting WiFi credentials"
  set_wifi_credentials
}

update_everything() {
  info "Updating packages"
  out=$(sudo apt-get update && sudo apt-get upgrade -y)
}

install_apps() {
  info "Installing docker"
  out=$(curl -sSL https://get.docker.com | sh)
  
  info "Installing vim"
  out=$(sudo apt-get install vim -y)
  
  info "Installing git"
  out=$(sudo apt-get install git -y)
}

set_wifi_credentials() {
  sudo bash -c "cat >> /etc/wpa_supplicant/wpa_supplicant.conf" <<EOF
network={
  ssid="$wifi_ssid"
  psk="$wifi_pass"
}
EOF
  sudo iwconfig wlan0 power off
}

ask() {
  printf "${MAGENTA}[PROFILE]${NC} $1 "
}

info() {
  printf "${CYAN}[PROFILE]${NC} $1\n"
}

success() {
  printf "${GREEN}[PROFILE]${NC} $1\n"
}

main
