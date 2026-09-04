#!/usr/bin/env bash

set -euo pipefail

current_date="$(date)"
host_name="$(hostname)"
user_name="$(whoami)"

echo "Current date: $current_date"
echo "Hostname: $host_name"
echo "Username: $user_name"

echo
echo "Disk usage:"
df -h

echo
echo "Running processes:"
ps

read -r -p "Enter a directory name: " directory_name
read -r -p "Enter an output file name: " output_file_name

mkdir -p -- "$directory_name"
output_path="$directory_name/$output_file_name"
touch -- "$output_path"
ps > "$output_path"

echo "Created directory: $directory_name"
echo "Created process report: $output_path"
