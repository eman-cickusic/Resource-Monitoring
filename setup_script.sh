#!/bin/bash

# Google Cloud Monitoring Lab Setup Script
# This script automates the setup of monitoring resources

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
PROJECT_ID=$(gcloud config get-value project)
REGION="us-central1"
ZONES=("us-central1-a" "us-central1-b" "us-central1-c")
VM_NAMES=("nginxstack-1" "nginxstack-2" "nginxstack-3")

echo -e "${GREEN}Starting Google Cloud Monitoring Lab Setup...${NC}"
echo "Project ID: $PROJECT_ID"
echo "Region: $REGION"

# Function to print status
print_status() {
    echo -e "${YELLOW}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Enable required APIs
print_status "Enabling required APIs..."
gcloud services enable compute.googleapis.com
gcloud services enable monitoring.googleapis.com
gcloud services enable logging.googleapis.com
print_success "APIs enabled"

# Create firewall rule for HTTP traffic
print_status "Creating firewall rule..."
if ! gcloud compute firewall-rules describe allow-http &> /dev/null; then
    gcloud compute firewall-rules create allow-http \
        --allow tcp:80 \
        --source-ranges 0.0.0.0/0 \
        --target-tags http-server \
        --description "Allow HTTP traffic for monitoring lab"
    print_success "Firewall rule created"
else
    print_status "Firewall rule already exists"
fi

# Create VM instances
print_status "Creating VM instances..."
for i in "${!VM_NAMES[@]}"; do
    VM_NAME="${VM_NAMES[$i]}"
    ZONE="${ZONES[$i]}"
    
    if ! gcloud compute instances describe "$VM_NAME" --zone="$ZONE" &> /dev/null; then
        print_status "Creating $VM_NAME in $ZONE..."
        gcloud compute instances create "$VM_NAME" \
            --zone="$ZONE" \
            --machine-type=e2-micro \
            --image-family=ubuntu-2004-lts \
            --image-project=ubuntu-os-cloud \
            --tags=http-server \
            --metadata=startup-script='#!/bin/bash
            apt update
            apt install -y nginx
            systemctl start nginx
            systemctl enable nginx
            
            # Install Cloud Ops Agent
            curl -sSO https://dl.google.com/cloudagents/add-google-cloud-ops-agent-repo.sh
            bash add-google-cloud-ops-agent-repo.sh --also-install
            '
        print_success "$VM_NAME created"
    else
        print_status "$VM_NAME already exists"
    fi
done

# Wait for instances to be ready
print_status "Waiting for instances to be ready..."
sleep 30

# Get external IPs and test connectivity
print_status "Testing instance connectivity..."
for i in "${!VM_NAMES[@]}"; do
    VM_NAME="${VM_NAMES[$i]}"
    ZONE="${ZONES[$i]}"
    
    EXTERNAL_IP=$(gcloud compute instances describe "$VM_NAME" \
        --zone="$ZONE" \
        --format="get(networkInterfaces[0].accessConfigs[0].natIP)")
    
    echo "  $VM_NAME: $EXTERNAL_IP"
    
    # Test HTTP connectivity (with retries)
    for attempt in {1..5}; do
        if curl -s --connect-timeout 5 "http://$EXTERNAL_IP" > /dev/null; then
            print_success "  HTTP test passed for $VM_NAME"
            break
        else
            if [ $attempt -eq 5 ]; then
                print_error "  HTTP test failed for $VM_NAME after 5 attempts"
            else
                print_status "  HTTP test attempt $attempt failed for $VM_NAME, retrying..."
                sleep 10
            fi
        fi
    done
done

# Create notification channel
print_status "Setting up email notification channel..."
echo "Please enter your email address for notifications:"
read -r EMAIL_ADDRESS

if [ -n "$EMAIL_ADDRESS" ]; then
    CHANNEL_JSON=$(cat <<EOF
{
  "type": "email",
  "displayName": "Lab Email Notifications",
  "labels": {
    "email_address": "$EMAIL_ADDRESS"
  }
}
EOF
)
    
    echo "$CHANNEL_JSON" > /tmp/notification-channel.json
    
    # Create notification channel via API
    CHANNEL_RESULT=$(gcloud alpha monitoring channels create --channel-content-from-file=/tmp/notification-channel.json --format="value(name)")
    print_success "Notification channel created: $CHANNEL_RESULT"
    
    # Save channel ID for later use
    echo "$CHANNEL_RESULT" > .notification-channel-id
    
    rm /tmp/notification-channel.json
else
    print_status "Skipping notification channel setup"
fi

print_success "Setup completed successfully!"
echo ""
echo -e "${GREEN}Next Steps:${NC}"
echo "1. Open Google Cloud Console"
echo "2. Navigate to Monitoring"
echo "3. Follow the lab instructions in README.md"
echo ""
echo -e "${YELLOW}Instance Details:${NC}"
for i in "${!VM_NAMES[@]}"; do
    VM_NAME="${VM_NAMES[$i]}"
    ZONE="${ZONES[$i]}"
    EXTERNAL_IP=$(gcloud compute instances describe "$VM_NAME" \
        --zone="$ZONE" \
        --format="get(networkInterfaces[0].accessConfigs[0].natIP)" 2>/dev/null || echo "N/A")
    echo "  $VM_NAME ($ZONE): http://$EXTERNAL_IP"
done