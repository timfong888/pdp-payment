#!/bin/bash

# Array of repositories to update
repos=("client-contract" "payments" "fil-forwarder-frontend" "dagparts" "pdp-explorer" "deal-bounty-contract" "pdp" "FilForwarder")

# Function to update a repository
update_repo() {
  local repo=$1
  echo "Updating repository: $repo"
  echo "------------------------"
  
  if [ -d "$repo" ]; then
    cd "$repo"
    
    # Check if there are any uncommitted changes
    if [ -n "$(git status --porcelain)" ]; then
      echo "⚠️  Repository has uncommitted changes. Skipping pull."
    else
      # Try to pull
      git pull
    fi
    
    cd ..
    echo ""
  else
    echo "❌ Directory not found: $repo"
    echo ""
  fi
}

# Main script
echo "Starting repository updates..."
echo "=============================="
echo ""

# Update each repository
for repo in "${repos[@]}"; do
  update_repo "$repo"
done

echo "=============================="
echo "Repository updates completed!"
