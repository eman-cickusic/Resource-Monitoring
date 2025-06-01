# Setup Guide - Google Cloud Monitoring Lab

## Environment Setup

### Prerequisites
- Google Cloud Platform account
- Project with billing enabled
- Appropriate IAM permissions for monitoring

### Required Permissions
Ensure your user account has the following roles:
```
- Monitoring Admin
- Compute Instance Admin
- Project Editor (or specific resource permissions)
```

## Initial VM Instance Setup

If you need to recreate the lab environment, here are the VM specifications:

### VM Configuration
```bash
# Create VM instances for monitoring
gcloud compute instances create nginxstack-1 \
    --zone=us-central1-a \
    --machine-type=e2-micro \
    --image-family=ubuntu-2004-lts \
    --image-project=ubuntu-os-cloud \
    --tags=http-server

gcloud compute instances create nginxstack-2 \
    --zone=us-central1-b \
    --machine-type=e2-micro \
    --image-family=ubuntu-2004-lts \
    --image-project=ubuntu-os-cloud \
    --tags=http-server

gcloud compute instances create nginxstack-3 \
    --zone=us-central1-c \
    --machine-type=e2-micro \
    --image-family=ubuntu-2004-lts \
    --image-project=ubuntu-os-cloud \
    --tags=http-server
```

### Install Nginx on Instances
```bash
# SSH into each instance and run:
sudo apt update
sudo apt install -y nginx
sudo systemctl start nginx
sudo systemctl enable nginx
```

## Monitoring Agent Installation

### Install Cloud Monitoring Agent
```bash
# On each VM instance
curl -sSO https://dl.google.com/cloudagents/add-google-cloud-ops-agent-repo.sh
sudo bash add-google-cloud-ops-agent-repo.sh --also-install
```

## Network Configuration

### Firewall Rules
```bash
# Allow HTTP traffic
gcloud compute firewall-rules create allow-http \
    --allow tcp:80 \
    --source-ranges 0.0.0.0/0 \
    --target-tags http-server \
    --description "Allow HTTP traffic"
```

## Verification Steps

### 1. Verify VM Instances
```bash
gcloud compute instances list
```

### 2. Test HTTP Endpoints
```bash
# Get external IPs
gcloud compute instances describe nginxstack-1 --zone=us-central1-a --format="get(networkInterfaces[0].accessConfigs[0].natIP)"

# Test connectivity
curl http://[EXTERNAL_IP]
```

### 3. Verify Monitoring Agent
```bash
# On each VM
sudo systemctl status google-cloud-ops-agent
```

## Common Setup Issues

### Issue: Monitoring metrics not appearing
**Solution**: 
- Ensure Cloud Monitoring API is enabled
- Verify monitoring agent installation
- Check IAM permissions

### Issue: VM instances not visible in monitoring
**Solution**:
- Wait 5-10 minutes for metrics to populate
- Refresh the Cloud Console
- Verify instances are running

### Issue: Uptime checks failing
**Solution**:
- Verify firewall rules allow HTTP traffic
- Check nginx service status
- Confirm external IP accessibility

## Environment Cleanup

### Remove Resources
```bash
# Delete VM instances
gcloud compute instances delete nginxstack-1 nginxstack-2 nginxstack-3 \
    --zones=us-central1-a,us-central1-b,us-central1-c

# Delete firewall rules
gcloud compute firewall-rules delete allow-http
```

## Next Steps
Once setup is complete, proceed to the main lab instructions in README.md
