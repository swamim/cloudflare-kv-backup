#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# Function to display usage
usage() {
  echo "Usage: $0 [OPTIONS]"
  echo ""
  echo "Options:"
  echo "  1) List Keys"
  echo "  2) Get Key Value"
  echo "  3) Backup All Keys to Local Folder"
  echo "  4) Update Key Value"
  exit 1
}

# Function to list all keys
list_keys() {
  echo "Fetching keys from KV namespace..."
  KEYS_JSON=$(wrangler kv:key list --namespace-id "$KV_NAMESPACE_ID")

  # Check if the KEYS_JSON is empty
  if [[ -z "$KEYS_JSON" ]]; then
    echo "No keys found in the namespace."
    exit 0
  fi

  echo "Listing all keys:"
  echo "$KEYS_JSON" | jq -r '.[].name'
}

# Function to get the value of a specific key
get_key_value() {
  echo "Fetching value for key: $KEY"
  VALUE=$(wrangler kv:key get --namespace-id "$KV_NAMESPACE_ID" "$KEY")

  if [[ -z "$VALUE" ]]; then
    echo "Key '$KEY' not found or has no value."
    exit 1
  fi

  echo "Value for key '$KEY':"
  echo "$VALUE"
}

# Function to back up all keys and values
backup_keys() {
  echo "Fetching keys from KV namespace..."
  KEYS_JSON=$(wrangler kv:key list --namespace-id "$KV_NAMESPACE_ID")

  if [[ -z "$KEYS_JSON" ]]; then
    echo "No keys found in the namespace."
    exit 0
  fi

  echo "$KEYS_JSON" | jq -r '.[].name' | while read -r key; do
    # Generate a sanitized file path for the key
    SAFE_KEY=$(echo "$key" | sed 's/[\/:*?"<>|]/_/g')
    DEST_FILE="$DEST_DIR/$SAFE_KEY"

    if [[ -f "$DEST_FILE" ]]; then
      echo "Key '$key' already backed up; skipping."
      continue
    fi

    echo "Backing up key: $key"

    # Fetch the value for the key
    VALUE=$(wrangler kv:key get --namespace-id "$KV_NAMESPACE_ID" "$key")

    # Save the value to the destination file
    echo "$VALUE" > "$DEST_FILE"
  done

  echo "Backup completed successfully. All KV pairs saved to '$DEST_DIR'."
}

# Function to update the value of a specific key
update_key_value() {
  echo "Updating value for key: $KEY"
  # Set the new value for the key
  wrangler kv:key put --namespace-id "$KV_NAMESPACE_ID" "$KEY" "$NEW_VALUE"
  echo "Key '$KEY' updated successfully with new value."
}

# Ask for user selection
echo "Please choose an option:"
echo "1) List Keys"
echo "2) Get Key Value"
echo "3) Backup All Keys to Local Folder"
echo "4) Update Key Value"
read -p "Enter your choice (1/2/3/4): " choice

# Ask for the Namespace ID
read -p "Enter the Cloudflare KV namespace ID: " KV_NAMESPACE_ID

# Handle the selection
case $choice in
  1)
    # List keys
    list_keys
    ;;
  2)
    # Get key value
    read -p "Enter the key to retrieve its value: " KEY
    get_key_value
    ;;
  3)
    # Backup keys to local folder
    read -p "Enter the destination folder for the backup: " DEST_DIR

    # Ensure destination directory exists
    mkdir -p "$DEST_DIR"
    backup_keys
    ;;
  4)
    # Update key value
    read -p "Enter the key to update: " KEY
    read -p "Enter the new value for key '$KEY': " NEW_VALUE
    update_key_value
    ;;
  *)
    echo "Invalid choice. Exiting."
    exit 1
    ;;
esac

