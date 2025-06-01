# Troubleshooting Guide - Google Cloud Monitoring Lab

## Common Issues and Solutions

### 1. VM Instances Not Visible in Monitoring

**Symptoms:**
- VM instances don't appear in monitoring dashboards
- Metrics are not being collected

**Solutions:**
1. **Check VM Status**
   ```bash
   gcloud compute instances list
   ```

2. **Verify Monitoring Agent Installation**
   ```bash
   # SSH into VM instance
   sudo systemctl status google-cloud-ops-agent
   ```

3. **Reinstall Monitoring Agent**
   ```bash
   curl -sSO https://dl.google.com/cloudagents/add-google-cloud-ops-agent-repo.sh
   sudo bash add-google-cloud-ops-agent-repo.sh --also-install
   ```

4. **Wait for Metrics Population**
   - Metrics can take 5-10 minutes to appear
   - Refresh the Cloud Console

### 2. CPU Utilization Metric Not Found

**Symptoms:**
- "CPU utilization" doesn't appear in metric dropdown
- Error: "No matching time series"

**Solutions:**
1. **Uncheck "Active" Filter**
   - In metric selection, uncheck the "Active" checkbox
   - This shows all available metrics, not just active ones

2. **Try Alternative Metrics**
   ```
   - compute.googleapis.com/instance/cpu/utilization
   - agent.googleapis.com/cpu/utilization
   ```

3. **Verify Resource Type**
   - Ensure "VM Instance" is selected as resource type
   - Check that instances are running

### 3. Alert Notifications Not Received

**Symptoms:**
- Alert policies are triggered but no emails received
- Notification channels seem configured but inactive

**Solutions:**
1. **Check Email Configuration**
   - Verify email address is correct
   - Check spam/junk folder
   - Confirm email verification (if required)

2. **Test Notification Channel**
   ```bash
   # List notification channels
   gcloud alpha monitoring channels list
   
   # Test specific channel
   gcloud alpha monitoring channels verify [CHANNEL_ID]
   ```

3. **Review Alert Policy Configuration**
   - Ensure notification channels are linked to alert policy
   - Check alert policy is enabled
   - Verify threshold values are appropriate

### 4. Uptime Checks Failing

**Symptoms:**
- Uptime checks show constant failures
- External IP not accessible

**Solutions:**
1. **Verify Firewall Rules**
   ```bash
   # Check existing firewall rules
   gcloud compute firewall-rules list --filter="name:allow-http"
   
   # Create if missing
   gcloud compute firewall-rules create allow-http \
       --allow tcp:80 \
       --source-ranges 0.0.0.0/0 \
       --target-tags http-server
   ```

2. **Check VM Network Tags**
   ```bash
   # Verify VM has http-server tag
   gcloud compute instances describe [INSTANCE_NAME] \
       --zone=[ZONE] --format="get(tags.items)"
   ```

3. **Test HTTP Connectivity**
   ```bash
   # Get external IP
   EXTERNAL_IP=$(gcloud compute instances describe [INSTANCE_NAME] \
       --zone=[ZONE] --format="get(networkInterfaces[0].accessConfigs[0].natIP)")
   
   # Test connectivity
   curl -I http://$EXTERNAL_IP
   ```

4. **Verify Nginx Status**
   ```bash
   # SSH into VM and check nginx
   sudo systemctl status nginx
   sudo systemctl start nginx  # if not running
   ```

### 5. Dashboard Charts Not Loading

**Symptoms:**
- Charts show "No data available"
- Spinning loading indicators
- Blank dashboard widgets

**Solutions:**
1. **Adjust Time Range**
   - Try different time ranges (1 hour, 6 hours, 1 day)
   - Ensure time range includes when instances were running

2. **Check Metric Filters**
   - Remove or adjust filters that might be too restrictive
   - Verify resource labels match actual instances

3. **Refresh Browser Cache**
   - Hard refresh (Ctrl+F5 or Cmd+Shift+R)
   - Clear browser cache
   - Try incognito/private browsing mode

### 6. Resource Groups Not Showing Instances

**Symptoms:**
- Resource groups are empty
- Instances don't match group criteria

**Solutions:**
1. **Review Group Criteria**
   - Check filter criteria (e.g., "contains nginx")
   - Verify instance names match the filter
   - Try broader criteria initially

2. **Check Instance Labels**
   ```bash
   # View instance details including labels
   gcloud compute instances describe [INSTANCE_NAME] --zone=[ZONE]
   ```

3. **Update Group Criteria**
   - Use instance names, zones, or other identifying characteristics
   - Test with single criterion first, then add more

### 7. Permissions Issues

**Symptoms:**
- "Access denied" errors
- Cannot create monitoring resources
- API calls fail with permission errors

**Solutions:**
1. **Check IAM Roles**
   ```bash
   # Check current user roles
   gcloud projects get-iam-policy [PROJECT_ID] \
       --flatten="bindings[].members" \
       --filter="bindings.members:[YOUR_EMAIL]"
   ```

2. **Required Roles:**
   - Monitoring Admin
   - Compute Instance Admin (for VM operations)
   - Project Editor (or specific resource permissions)

3. **Enable APIs**
   ```bash
   gcloud services enable monitoring.googleapis.com
   gcloud services enable compute.googleapis.com
   gcloud services enable logging.googleapis.com
   ```

### 8. Metrics Explorer Issues

**Symptoms:**
- Limited metrics available
- Cannot recreate dashboard charts
- Metrics don't match dashboard options

**Solutions:**
1. **Use Correct Metric Names**
   - Dashboard: "CPU utilization" (friendly name)
   - Metrics Explorer: "compute.googleapis.com/instance/cpu/utilization" (full path)

2. **Check Resource Types**
   - Ensure consistent resource type selection
   - Try "gce_instance" if "VM Instance" doesn't work

3. **Time Alignment**
   - Adjust alignment period (1m, 5m, etc.)
   - Try different aggregation methods (mean, sum, max)

## Performance Optimization

### Reducing Monitoring Costs
1. **Optimize Metric Collection**
   - Collect only necessary metrics
   - Adjust collection intervals
   - Use appropriate retention periods

2. **Efficient Alerting**
   - Avoid overly sensitive thresholds
   - Use appropriate evaluation periods
   - Group related alerts

### Improving Dashboard Performance
1. **Limit Time Ranges**
   - Use shorter time windows for detailed analysis
   - Implement appropriate refresh intervals

2. **Optimize Queries**
   - Use specific filters
   - Aggregate data appropriately
   - Limit concurrent queries

## Getting Help

### Google Cloud Support Resources
- [Cloud Monitoring Documentation](https://cloud.google.com/monitoring/docs)
- [Troubleshooting Guide](https://cloud.google.com/monitoring/support/troubleshooting)
- [Community Forums](https://cloud.google.com/community)

### Debug Commands
```bash
# Check API status
gcloud services list --enabled --filter="monitoring"

# View recent operations
gcloud logging read "resource.type=gce_instance" --limit=10

# Test connectivity
gcloud compute instances list --filter="status:RUNNING"

# Monitor agent logs
sudo journalctl -u google-cloud-ops-agent -f
```

### Contact Information
For additional support:
- Create issues in this repository
- Check Google Cloud Status page
- Contact Google Cloud Support (if you have a support plan)
