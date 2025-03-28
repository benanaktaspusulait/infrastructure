#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to generate secure password
generate_password() {
    openssl rand -base64 32
}

# Function to check if a file exists
check_file() {
    if [ ! -f "$1" ]; then
        echo -e "${RED}Error: $1 not found${NC}"
        exit 1
    fi
}

# Function to backup file
backup_file() {
    if [ -f "$1" ]; then
        cp "$1" "$1.$(date +%Y%m%d_%H%M%S).bak"
        echo -e "${GREEN}Backed up $1${NC}"
    fi
}

# Function to update terraform.tfvars
update_tfvars() {
    local key=$1
    local value=$2
    local file="terraform.tfvars"
    
    # Backup existing file
    backup_file "$file"
    
    # Update or add the variable
    if grep -q "^$key" "$file"; then
        sed -i '' "s|^$key.*|$key = \"$value\"|" "$file"
    else
        echo "$key = \"$value\"" >> "$file"
    fi
    
    echo -e "${GREEN}Updated $key in $file${NC}"
}

# Main menu
while true; do
    echo -e "\n${YELLOW}Secret Management Menu${NC}"
    echo "1. Generate new secrets"
    echo "2. Update specific secret"
    echo "3. Rotate all secrets"
    echo "4. Backup secrets"
    echo "5. Exit"
    read -p "Select an option (1-5): " choice

    case $choice in
        1)
            echo -e "\n${YELLOW}Generating new secrets...${NC}"
            
            # Generate new secrets
            postgresql_password=$(generate_password)
            kafka_password=$(generate_password)
            redis_password=$(generate_password)
            jwt_secret=$(generate_password)
            encryption_key=$(generate_password)
            
            # Update terraform.tfvars
            update_tfvars "postgresql_password" "$postgresql_password"
            update_tfvars "kafka_password" "$kafka_password"
            update_tfvars "redis_password" "$redis_password"
            update_tfvars "jwt_secret" "$jwt_secret"
            update_tfvars "encryption_key" "$encryption_key"
            
            echo -e "${GREEN}New secrets generated and updated${NC}"
            ;;
            
        2)
            echo -e "\n${YELLOW}Available secrets:${NC}"
            echo "1. PostgreSQL Password"
            echo "2. Kafka Password"
            echo "3. Redis Password"
            echo "4. JWT Secret"
            echo "5. Encryption Key"
            read -p "Select a secret to update (1-5): " secret_choice
            
            case $secret_choice in
                1) update_tfvars "postgresql_password" "$(generate_password)" ;;
                2) update_tfvars "kafka_password" "$(generate_password)" ;;
                3) update_tfvars "redis_password" "$(generate_password)" ;;
                4) update_tfvars "jwt_secret" "$(generate_password)" ;;
                5) update_tfvars "encryption_key" "$(generate_password)" ;;
                *) echo -e "${RED}Invalid option${NC}" ;;
            esac
            ;;
            
        3)
            echo -e "\n${YELLOW}Rotating all secrets...${NC}"
            # Generate and update all secrets
            for key in postgresql_password kafka_password redis_password jwt_secret encryption_key; do
                update_tfvars "$key" "$(generate_password)"
            done
            echo -e "${GREEN}All secrets rotated${NC}"
            ;;
            
        4)
            echo -e "\n${YELLOW}Backing up secrets...${NC}"
            backup_file "terraform.tfvars"
            echo -e "${GREEN}Secrets backed up${NC}"
            ;;
            
        5)
            echo -e "\n${YELLOW}Exiting...${NC}"
            exit 0
            ;;
            
        *)
            echo -e "${RED}Invalid option${NC}"
            ;;
    esac
done 