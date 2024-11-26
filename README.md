# cloudflare-kv-backup

This script provides a handy CLI to manage Cloudflare KV with functionalities such as listing keys, fetching key values, backing up data, and updating key values. Below is a breakdown of its functionality and usage:

Features
List Keys
Lists all keys in a specified KV namespace.

Get Key Value
Retrieves the value associated with a specific key in the KV store.

Backup All Keys to Local Folder
Saves all keys and their values to a designated local directory. Filenames are sanitized to avoid issues with filesystem restrictions.

Update Key Value
Updates a specified key with a new value in the KV namespace.


**Prerequisites**
Install Wrangler
Ensure you have Wrangler installed:
  npm install -g wrangler
  
Cloudflare API Authentication
Configure Wrangler with your Cloudflare API token:
  wrangler login
  
Ensure jq is Installed
Install jq for parsing JSON data:
  sudo apt install jq       # Debian/Ubuntu
  brew install jq           # macOS
  choco install jq          # Windows
