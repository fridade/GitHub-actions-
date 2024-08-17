#!/bin/bash

# Usage: ./get_cloud_run_ip.sh <region> <service_name>
# Example: ./get_cloud_run_ip.sh us-central1 php-app

# Exit immediately if a command exits with a non-zero status
set -e

# Log file for script execution details
LOG_FILE="cloud_run_ip.log"

# Function to log messages with timestamp
log_message() {
  local message="$1"
  echo "$(date +"%Y-%m-%d %H:%M:%S") - ${message}" >> "${LOG_FILE}"
}

# Check if region and service name arguments are provided
if [ "$#" -ne 2 ]; then
  echo "Error: Region and service name are required."
  echo "Usage: $0 <region> <service_name>"
  exit 1
fi

REGION=$1
SERVICE_NAME=$2
PROJECT_ID="${{ secrets.GCP_PROJECT_ID }}"  # This should be set in the GitHub Actions secrets

# Log the start of the script execution
log_message "Starting script to retrieve IP address for service: ${SERVICE_NAME} in region: ${REGION}"

# Retrieve the public URL of the Cloud Run service
PUBLIC_URL=$(gcloud run services describe "${SERVICE_NAME}" \
  --project "${PROJECT_ID}" \
  --region "${REGION}" \
  --format="value(status.address.url)" 2>&1)

# Check if the command was successful
if [ $? -ne 0 ]; then
  log_message "Error: Failed to retrieve IP address. Output: ${PUBLIC_URL}"
  echo "Failed to retrieve IP address. Check the log file for details."
  exit 1
fi

# Log the retrieved URL
log_message "Successfully retrieved public URL: ${PUBLIC_URL}"

# Output the URL to the user
echo "Public URL of the Cloud Run service: ${PUBLIC_URL}"
