#!/bin/bash

# Create directory for filecoin-project repositories
mkdir -p filecoin-project

# List of repositories to clone
repos=(
  "lotus"
  "venus"
  "fevm-hardhat-kit"
  "boost"
  "specs-actors"
  "builtin-actors"
)

# Clone each repository
for repo in "${repos[@]}"; do
  echo "Cloning $repo..."
  if [ -d "filecoin-project/$repo" ]; then
    echo "Repository $repo already exists, skipping..."
  else
    git clone "https://github.com/filecoin-project/$repo.git" "filecoin-project/$repo"
  fi
done

echo "All repositories cloned successfully!"
