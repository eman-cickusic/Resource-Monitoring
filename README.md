# Resource Monitoring

This repository contains a comprehensive guide for working with Google Cloud Monitoring, including creating custom dashboards, alerting policies, resource groups, and uptime checks.

## Video

https://youtu.be/35EU6UG-BeI

## Overview

This lab demonstrates how to use Cloud Monitoring to gain insight into applications running on Google Cloud Platform. You'll learn to monitor VM instances, create custom dashboards, set up alerts, organize resources into groups, and implement uptime monitoring.

## Objectives

By completing this lab, you will learn to:
- ✅ Explore Cloud Monitoring by creating custom dashboards with charts
- ✅ Create alerts with multiple conditions
- ✅ Create resource groups for better organization
- ✅ Create uptime checks for availability monitoring
- ✅ Configure notification channels for alerts

## Prerequisites

- Google Cloud Platform account
- Basic understanding of GCP services
- Access to a GCP project with billing enabled

## Lab Setup

### Initial Resources
The lab environment includes three pre-configured VM instances:
- `nginxstack-1`
- `nginxstack-2` 
- `nginxstack-3`

These instances serve as the monitoring targets for this lab.

## Step-by-Step Guide

### Task 1: Create a Cloud Monitoring Workspace

1. **Navigate to Monitoring**
   ```
   Google Cloud Console → Search "Monitoring" → Select Monitoring
   ```

2. **Workspace Provisioning**
   - Wait for workspace to be automatically provisioned
   - Workspace will be tied to your current GCP project

3. **Verify VM Instances**
   ```
   Navigation Menu → Compute Engine → VM Instances
   ```
   Confirm the three nginx instances are running.

### Task 2: Custom Dashboards

#### Create Dashboard
1. Navigate to `Dashboards` in the left pane
2. Click `+ Create Dashboard`
3. Name: `My Dashboard`

#### Add CPU Utilization Chart
1. Click `Add Widget` → Select `Line`
2. Configure the chart:
   - **Widget Title**: Custom name for your chart
   - **Metric**: Search for "CPU utilization" or "CPU usage"
   - **Resource**: VM Instance → Instance
   - **Metric**: CPU utilization/usage
3. Add filters as needed
4. Click `Apply` to create the chart

#### Explore Metrics Explorer
- Navigate to `Metrics Explorer` in left pane
- Recreate the dashboard chart using different interface
- Experiment with various metrics and visualization options

### Task 3: Alerting Policies

#### Create Multi-Condition Alert
1. Navigate to `Alerting` → `+ Create Policy`

2. **First Condition Setup**:
   - Metric: VM Instance → CPU usage/utilization
   - Rolling window: 1 minute
   - Threshold: Above 20%

3. **Add Second Condition**:
   - Click `+ ADD ALERT CONDITION`
   - Configure similar condition for different instance
   - Multi-condition trigger: "All conditions are met"

4. **Configure Notifications**:
   - Set up email notification channel
   - Add personal email address
   - Assign display name
   - Link notification channel to alert policy

### Task 4: Resource Groups

1. Navigate to `Groups` → `+ Create Group`
2. **Group Configuration**:
   - Name: `VM instances`
   - Criteria: Contains "nginx"
3. Review the auto-generated group dashboard

### Task 5: Uptime Monitoring

#### Create Uptime Check
1. Navigate to `Uptime Checks` → `+ Create Uptime Check`

2. **Configuration**:
   ```
   Protocol: HTTP
   Resource Type: Instance
   Applies To: Group
   Group: [Your created group]
   Check Frequency: 1 minute
   ```

3. **Alert Configuration**:
   - Link to notification channels
   - Set appropriate title
   - Test connectivity before creating

### Task 6: Alert Management

#### Disable Alerts (Cleanup)
1. Navigate to `Alerting` → View all policies
2. Toggle `Enabled` switch to disable
3. Confirm disable action

## Key Features Implemented

### 🔍 **Monitoring Dashboard**
- Custom CPU utilization charts
- Multi-instance monitoring
- Real-time metrics visualization

### 🚨 **Advanced Alerting**
- Multi-condition alert policies
- Email notification integration
- Threshold-based triggering

### 📊 **Resource Organization**
- Logical resource grouping
- Criteria-based filtering
- Automated dashboard generation

### ⏱️ **Uptime Monitoring**
- HTTP endpoint availability checks
- Automated failure notifications
- Configurable check intervals

## Best Practices Learned

### Alerting Best Practices ✅
- ✅ Use multiple notification channels (avoid single point of failure)
- ✅ Configure alerts on symptoms, not just causes
- ✅ Customize alerts for audience needs
- ❌ Avoid reporting all noise - filter meaningfully

### Valid Notification Targets
- ✅ Email
- ✅ SMS  
- ✅ Webhook
- ✅ Pub/Sub
- ✅ 3rd party services

## File Structure

```
google-cloud-monitoring-lab/
├── README.md
├── docs/
│   ├── setup-guide.md
│   ├── troubleshooting.md
│   └── best-practices.md
├── configs/
│   ├── dashboard-config.json
│   ├── alert-policy.json
│   └── uptime-check-config.json
├── scripts/
│   ├── setup-monitoring.sh
│   └── cleanup-resources.sh
└── screenshots/
    ├── dashboard-example.png
    ├── alert-config.png
    └── uptime-check.png
```

## Troubleshooting

### Common Issues
- **Metric not found**: Uncheck "Active" filter in metric selection
- **VM instances not visible**: Refresh browser page
- **Notification not received**: Verify email address and check spam folder

### Resource Cleanup
Remember to disable alert policies in lab environments to prevent ongoing notifications after project deletion.

## Next Steps

After completing this lab, consider exploring:
- Custom metrics with Cloud Monitoring API
- Integration with Cloud Logging
- Advanced dashboard configurations
- Monitoring for other GCP services (Cloud SQL, App Engine, etc.)

## Resources

- [Google Cloud Monitoring Documentation](https://cloud.google.com/monitoring/docs)
- [Alerting Best Practices](https://cloud.google.com/monitoring/alerts/best-practices)
- [Dashboard Configuration Guide](https://cloud.google.com/monitoring/dashboards)

## Contributing

Feel free to submit issues and enhancement requests. Pull requests are welcome!

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
