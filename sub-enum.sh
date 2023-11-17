#!/bin/bash

# ANSI color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Prompt the user to enter the domain
read -p "Enter the target domain: " domain

if [ -z "$domain" ]; then
  echo -e "${RED}Domain cannot be empty. Exiting.${NC}"
  exit 1
fi

output_file="subdomains.txt"

# Check if subfinder is installed
if ! command -v subfinder &> /dev/null; then
  echo -e "${RED}subfinder not found. Attempting to install subfinder...${NC}"
  
  # Check if sudo is required
  if command -v apt &> /dev/null; then
    sudo apt update
    sudo apt install -y subfinder || { echo -e "${RED}Installation of subfinder failed. Exiting.${NC}"; exit 1; }
  elif command -v pacman &> /dev/null; then
    # Adjust for other package managers as needed
    sudo pacman -S subfinder || { echo -e "${RED}Installation of subfinder failed. Exiting.${NC}"; exit 1; }
  else
    echo -e "${RED}Package manager not found. Manual installation of subfinder is required.${NC}"
    exit 1
  fi
  
  # Verify if installation was successful
  if ! command -v subfinder &> /dev/null; then
    echo -e "${RED}Installation of subfinder was not successful. Exiting.${NC}"
    exit 1
  fi
fi

echo -e "${GREEN}Enumerating subdomains for $domain using subfinder...${NC}"

# Run subfinder and save the results to a file
subfinder -d "$domain" -o subfinder.txt

echo -e "${GREEN}Subfinder enumeration complete.${NC}"

echo -e "${GREEN}Enumerating subdomains for $domain using assetfinder...${NC}"

# Run assetfinder and save the results to a file
assetfinder -subs-only "$domain"| tee assetfinder.txt

echo -e "${GREEN}Assetfinder enumeration complete.${NC}"

echo -e "${GREEN}Sorting the results...${NC}"

# Combine and sort the results into a single file
cat subfinder.txt assetfinder.txt | sort -u > "$output_file"

# Clean up temporary files
rm -f subfinder.txt assetfinder.txt

echo -e "${GREEN}Subdomain enumeration complete. Results saved to $output_file.${NC}"
