#!/usr/bin/env bash

set -u
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
work_dir="$repo_root/.evidence-work/system"
mkdir -p "$work_dir"
mkdir -p "$repo_root/linux-fundamentals/evidence"
mkdir -p "$repo_root/shell-scripting/evidence"
mkdir -p "$repo_root/networking/evidence"

linux_output="$repo_root/linux-fundamentals/evidence/linux-output.txt"
{
  echo "$ date --iso-8601=seconds"
  date --iso-8601=seconds
  echo
  echo "=== Soft link and hard link ==="
  cd "$work_dir"
  rm -f original.txt soft-link.txt hard-link.txt
  printf 'DevOps link practice\n' > original.txt
  ln -s original.txt soft-link.txt
  ln original.txt hard-link.txt
  echo "$ ls -li original.txt soft-link.txt hard-link.txt"
  ls -li original.txt soft-link.txt hard-link.txt
  echo "$ readlink soft-link.txt"
  readlink soft-link.txt
  rm -f soft-link.txt hard-link.txt original.txt
  echo "Practice files removed successfully."

  echo
  echo "=== adduser and useradd ==="
  echo "$ command -V adduser"
  command -V adduser
  echo "$ command -V useradd"
  command -V useradd
  sudo deluser --remove-home coursework-user >/dev/null 2>&1 || true
  echo "$ sudo adduser --disabled-password --gecos '' coursework-user"
  sudo adduser --disabled-password --gecos '' coursework-user
  echo "$ getent passwd coursework-user"
  getent passwd coursework-user
  echo "$ sudo deluser --remove-home coursework-user"
  sudo deluser --remove-home coursework-user

  echo
  echo "=== journalctl ==="
  echo "$ ps -p 1 -o comm="
  ps -p 1 -o comm=
  echo "$ journalctl --no-pager -n 20"
  journalctl --no-pager -n 20 || true
  echo "$ journalctl -u docker --since today --no-pager"
  journalctl -u docker --since today --no-pager || true

  echo
  echo "=== Linux command practice ==="
  echo "$ pwd"
  pwd
  echo "$ ls -lah"
  ls -lah
  echo "$ df -h /"
  df -h /
  echo "$ free -h"
  free -h
  echo "$ ps -ef"
  ps -ef
} > "$linux_output" 2>&1

shell_output="$repo_root/shell-scripting/evidence/system-info-output.txt"
(
  cd "$repo_root/shell-scripting"
  rm -rf system-info-output
  printf 'system-info-output\nprocesses.txt\n' | ./system-info.sh
  echo
  echo "$ ls -l system-info-output/processes.txt"
  ls -l system-info-output/processes.txt
  echo "$ head system-info-output/processes.txt"
  head system-info-output/processes.txt
  rm -rf system-info-output
) > "$shell_output" 2>&1

network_output="$repo_root/networking/evidence/networking-output.txt"
{
  echo "$ date --iso-8601=seconds"
  date --iso-8601=seconds
  echo
  echo "$ ip address show"
  ip address show
  echo
  echo "$ ip route show"
  ip route show
  echo
  echo "$ ping -c 4 google.com"
  ping -c 4 google.com || true
  echo
  echo "$ traceroute -m 8 google.com"
  traceroute -m 8 google.com || true
  echo
  echo "$ netstat -tuln"
  netstat -tuln
  echo
  echo "$ telnet google.com 80"
  printf 'HEAD / HTTP/1.0\r\nHost: google.com\r\n\r\n' |
    timeout 8 telnet google.com 80 || true
  echo
  echo "$ sudo tcpdump -nn -i any -c 5 host google.com"
  sudo timeout 12 tcpdump -nn -i any -c 5 host google.com &
  tcpdump_pid=$!
  sleep 1
  curl --silent --output /dev/null https://www.google.com || true
  wait "$tcpdump_pid" || true
  echo
  echo "$ nslookup google.com"
  nslookup google.com
  echo
  echo "$ dig google.com"
  dig google.com
  echo
  echo "$ curl -I https://www.google.com"
  curl --max-time 15 -I https://www.google.com || true
  echo
  echo "$ arp -a"
  arp -a || true
  echo "$ ip neigh"
  ip neigh
  echo
  echo "$ systemctl status NetworkManager"
  systemctl status NetworkManager --no-pager || true
} > "$network_output" 2>&1

echo "System evidence captured."
