#!/bin/bash
# Iranian APT Mirror Switcher - Safely and easily switch your Ubuntu/Debian APT sources
# between fast Iranian or official global mirrors. Minimal and robust, with clear status reporting.
# Author: Rzaphlvan
# Version: 1.0.1

RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
CYAN='\033[1;36m'
NC='\033[0m'

SRC_FILE="/etc/apt/sources.list"

detect_os_codename() {
  OS=""
  CODENAME=""
  if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS="$ID"
    CODENAME="$VERSION_CODENAME"
  fi
  if [ -z "$OS" ] || [ "$OS" = "ID" ]; then
    OS=$(lsb_release -is 2>/dev/null | tr '[:upper:]' '[:lower:]')
  fi
  if [ -z "$CODENAME" ] || [ "$CODENAME" = "VERSION_CODENAME" ]; then
    CODENAME=$(lsb_release -cs 2>/dev/null)
  fi
  if [ -z "$OS" ] && [ -f /etc/lsb-release ]; then
    . /etc/lsb-release
    OS="$DISTRIB_ID"
    CODENAME="$DISTRIB_CODENAME"
    OS=$(echo "$OS" | tr '[:upper:]' '[:lower:]')
  fi
  [ -z "$OS" ] && OS="unknown"
  [ -z "$CODENAME" ] && CODENAME="unknown"
}

show_iranian_menu() {
  echo -e "${GREEN}1) ArvanCloud   http://mirror.arvancloud.ir${NC}"
  echo -e "${CYAN}2) IranServer   http://mirror.iranserver.com${NC}"
  echo -e "${YELLOW}3) Hostiran     http://mirrors.hostiran.net${NC}"
  echo -e "${GREEN}4) Sharif       http://mirror.sharif.ir${NC}"
  echo -e "${CYAN}5) Asiatech     http://repo.asiatech.ir${NC}"
  echo -e "${YELLOW}6) Tebyan       http://mirrors.tebyan.net${NC}"
}

show_world_menu() {
  if [ "$OS" = "ubuntu" ]; then
    echo -e "${GREEN}1) Official Ubuntu     http://archive.ubuntu.com/ubuntu/${NC}"
    echo -e "${CYAN}2) Kernel.org         http://mirrors.edge.kernel.org/ubuntu/${NC}"
    echo -e "${YELLOW}3) US Archive         http://us.archive.ubuntu.com/ubuntu/${NC}"
  elif [ "$OS" = "debian" ]; then
    echo -e "${GREEN}1) Official Debian    http://deb.debian.org/debian/${NC}"
    echo -e "${CYAN}2) FTP Debian         http://ftp.debian.org/debian/${NC}"
    echo -e "${YELLOW}3) US Debian          http://ftp.us.debian.org/debian/${NC}"
  else
    echo -e "${RED}No world mirrors available for OS: $OS${NC}"
  fi
}

confirm_and_report() {
  # $1: expected string in the file
  grep -q "$1" "$SRC_FILE"
  FILE_OK=$?
  apt update &>/dev/null
  APT_OK=$?
  if [ $FILE_OK -eq 0 ] && [ $APT_OK -eq 0 ]; then
    echo -e "${GREEN}Sources updated and saved to $SRC_FILE ✔${NC}"
  elif [ $FILE_OK -ne 0 ]; then
    echo -e "${RED}Failed: Could not write to $SRC_FILE!${NC}"
  else
    echo -e "${RED}Sources written but apt update failed!${NC}"
  fi
}

set_recommended_iran() {
  if [ "$OS" = "ubuntu" ]; then
    echo "deb http://mirror.arvancloud.ir/ubuntu/ $CODENAME main restricted universe multiverse
deb http://mirror.iranserver.com/ubuntu/ $CODENAME main restricted universe multiverse
deb http://mirrors.hostiran.net/ubuntu/ $CODENAME main restricted universe multiverse
deb http://mirror.arvancloud.ir/ubuntu/ $CODENAME-updates main restricted universe multiverse
deb http://mirror.arvancloud.ir/ubuntu/ $CODENAME-security main restricted universe multiverse" > "$SRC_FILE" 2>/dev/null
    confirm_and_report "arvancloud.ir/ubuntu/"
  elif [ "$OS" = "debian" ]; then
    echo "deb http://mirror.arvancloud.ir/debian/ $CODENAME main contrib non-free
deb http://mirror.iranserver.com/debian/ $CODENAME main contrib non-free
deb http://mirrors.hostiran.net/debian/ $CODENAME main contrib non-free
deb http://mirror.arvancloud.ir/debian/ $CODENAME-updates main contrib non-free
deb http://mirror.arvancloud.ir/debian-security/ $CODENAME-security main contrib non-free" > "$SRC_FILE" 2>/dev/null
    confirm_and_report "arvancloud.ir/debian/"
  else
    echo -e "${RED}Failed${NC}"
  fi
}

set_world_all() {
  if [ "$OS" = "ubuntu" ]; then
    echo "deb http://archive.ubuntu.com/ubuntu/ $CODENAME main restricted universe multiverse
deb http://archive.ubuntu.com/ubuntu/ $CODENAME-updates main restricted universe multiverse
deb http://archive.ubuntu.com/ubuntu/ $CODENAME-backports main restricted universe multiverse
deb http://security.ubuntu.com/ubuntu/ $CODENAME-security main restricted universe multiverse" > "$SRC_FILE" 2>/dev/null
    confirm_and_report "archive.ubuntu.com/ubuntu/"
  elif [ "$OS" = "debian" ]; then
    echo "deb http://deb.debian.org/debian/ $CODENAME main contrib non-free
deb http://deb.debian.org/debian/ $CODENAME-updates main contrib non-free
deb http://deb.debian.org/debian-security/ $CODENAME-security main contrib non-free" > "$SRC_FILE" 2>/dev/null
    confirm_and_report "deb.debian.org/debian/"
  else
    echo -e "${RED}Failed${NC}"
  fi
}

set_iranian_single() {
  show_iranian_menu
  echo -en "${YELLOW}Number: ${NC}"
  read num
  base=""
  case "$num" in
    1) base="http://mirror.arvancloud.ir";;
    2) base="http://mirror.iranserver.com";;
    3) base="http://mirrors.hostiran.net";;
    4) base="http://mirror.sharif.ir";;
    5) base="http://repo.asiatech.ir";;
    6) base="http://mirrors.tebyan.net";;
    *) echo -e "${RED}Failed${NC}"; return;;
  esac
  if [ "$OS" = "ubuntu" ]; then
    echo "deb $base/ubuntu/ $CODENAME main restricted universe multiverse
deb $base/ubuntu/ $CODENAME-updates main restricted universe multiverse
deb $base/ubuntu/ $CODENAME-security main restricted universe multiverse" > "$SRC_FILE" 2>/dev/null
    confirm_and_report "$base/ubuntu/"
  elif [ "$OS" = "debian" ]; then
    echo "deb $base/debian/ $CODENAME main contrib non-free
deb $base/debian/ $CODENAME-updates main contrib non-free
deb $base/debian-security/ $CODENAME-security main contrib non-free" > "$SRC_FILE" 2>/dev/null
    confirm_and_report "$base/debian/"
  else
    echo -e "${RED}Failed${NC}"
  fi
}

set_world_single() {
  show_world_menu
  echo -en "${YELLOW}Number: ${NC}"
  read num
  if [ "$OS" = "ubuntu" ]; then
    case "$num" in
      1) base="http://archive.ubuntu.com/ubuntu/";;
      2) base="http://mirrors.edge.kernel.org/ubuntu/";;
      3) base="http://us.archive.ubuntu.com/ubuntu/";;
      *) echo -e "${RED}Failed${NC}"; return;;
    esac
    echo "deb $base $CODENAME main restricted universe multiverse
deb $base $CODENAME-updates main restricted universe multiverse
deb $base $CODENAME-backports main restricted universe multiverse
deb http://security.ubuntu.com/ubuntu/ $CODENAME-security main restricted universe multiverse" > "$SRC_FILE" 2>/dev/null
    confirm_and_report "$base"
  elif [ "$OS" = "debian" ]; then
    case "$num" in
      1) base="http://deb.debian.org/debian/";;
      2) base="http://ftp.debian.org/debian/";;
      3) base="http://ftp.us.debian.org/debian/";;
      *) echo -e "${RED}Failed${NC}"; return;;
    esac
    echo "deb $base $CODENAME main contrib non-free
deb $base $CODENAME-updates main contrib non-free
deb http://deb.debian.org/debian-security/ $CODENAME-security main contrib non-free" > "$SRC_FILE" 2>/dev/null
    confirm_and_report "$base"
  else
    echo -e "${RED}Failed${NC}"
  fi
}

fast_patch_arvancloud() {
  sed -i 's|http://[a-z]*\.archive\.ubuntu\.com|http://mirror.arvancloud.ir|g' "$SRC_FILE" 2>/dev/null
  sed -i 's|http://deb.debian.org/debian|http://mirror.arvancloud.ir/debian|g' "$SRC_FILE" 2>/dev/null
  confirm_and_report "arvancloud.ir"
}

print_sources() {
  echo -e "${CYAN}----- $SRC_FILE -----${NC}"
  cat "$SRC_FILE"
  echo -e "${CYAN}---------------------${NC}"
}

main_menu() {
  clear
  echo -e "${CYAN}========= Iranian APT Mirror Switcher =========${NC}"
  echo -e "${YELLOW}OS: $OS${NC}  ${CYAN}Codename: $CODENAME${NC}"
  echo -e "${GREEN}1)${NC} Recommended Iranian mirrors"
  echo -e "${CYAN}2)${NC} World/Official mirrors"
  echo -e "${YELLOW}3)${NC} Single Iranian mirror"
  echo -e "${CYAN}4)${NC} Single world mirror"
  echo -e "${GREEN}5)${NC} Fast patch ArvanCloud"
  echo -e "${CYAN}6)${NC} Show sources.list"
  echo -e "${YELLOW}0)${NC} Exit"
  echo -en "${YELLOW}Select: ${NC}"
}

detect_os_codename

while true; do
  main_menu
  read choice
  case "$choice" in
    1) set_recommended_iran ;;
    2) set_world_all ;;
    3) set_iranian_single ;;
    4) set_world_single ;;
    5) fast_patch_arvancloud ;;
    6) print_sources ;;
    0) echo -e "${CYAN}Bye${NC}"; exit 0 ;;
    *) echo -e "${RED}Failed${NC}" ;;
  esac
done