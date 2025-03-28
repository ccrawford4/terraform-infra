#!/bin/bash

# Validate input
if [ $# -lt 3 ]; then
  echo "Usage: $0 <bastion_host> <private_key_filename> <target_host>"
  echo "Example: $0 54.84.54.109 ec2-keypair-iqipfc4i.pem 10.0.101.174"
  exit 1
fi

# Assign arguments
BASTION_HOST=$1
PRIVATE_KEY=$2
TARGET_HOST=$3

# Full path to the private key
KEY_PATH="ec2/$PRIVATE_KEY"

# Validate file paths
if [ ! -f "$KEY_PATH" ]; then
  echo "Error: Private key file not found at $KEY_PATH"
  exit 1
fi

# SCP transfer
scp -r \
  -o "ProxyCommand=ssh -i '$KEY_PATH' ec2-user@$BASTION_HOST -W %h:%p" \
  -i "$KEY_PATH" \
  "ansible" \
  "ec2-user@$TARGET_HOST:."

# SSH into target (if needed)
ssh -o "ProxyCommand=ssh -i '$KEY_PATH' ec2-user@$BASTION_HOST -W %h:%p" \
  -i "$KEY_PATH" \
  "ec2-user@$TARGET_HOST"
