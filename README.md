# CI/CD Pipeline for PHP Application

## Overview

This guide provides instructions for setting up a CI/CD pipeline using GitHub Actions to automate the deployment of a PHP application to Google Cloud Run. The pipeline performs the following tasks:

1. Checks out the code repository.
2. Builds the Docker image.
3. Pushes the Docker image to Google Container Registry (GCR).
4. Deploys the application to Cloud Run.
5. Configures environment variables using GitHub secrets.
6. Includes unit/integration tests (if applicable).
7. Documents the workflow steps.

## Step-by-Step Setup

### Step 1: Create the GitHub Actions Workflow File

Create a new file in your repository: `.github/workflows/deploy.yml`.

### Step 2: Define the Workflow Structure

Add the following YAML configuration to `.github/workflows/deploy.yml`:

```yaml
name: CI/CD Pipeline for PHP Application

on:
  push:
    branches:
      - main

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest

    steps:
      # Step 1: Check out the code repository
      - name: Checkout Code
        uses: actions/checkout@v3

      # Step 2: Set up Google Cloud CLI
      - name: Set up Google Cloud SDK
        uses: google-github-actions/setup-gcloud@v1
        with:
          project_id: ${{ secrets.GCP_PROJECT_ID }}
          service_account_key: ${{ secrets.GCP_SA_KEY }}
          export_default_credentials: true

      # Step 3: Authenticate Docker to use Google Container Registry
      - name: Authenticate Docker with GCR
        run: |
          gcloud auth configure-docker --quiet

      # Step 4: Build the Docker image
      - name: Build Docker Image
        run: |
          docker build -t gcr.io/${{ secrets.GCP_PROJECT_ID }}/php-app:${{ github.sha }} .

      # Step 5: Push Docker image to GCR
      - name: Push Docker Image to GCR
        run: |
          docker push gcr.io/${{ secrets.GCP_PROJECT_ID }}/php-app:${{ github.sha }}

      # Step 6: Deploy to Cloud Run
      - name: Deploy to Cloud Run
        run: |
          gcloud run deploy php-app \
            --image gcr.io/${{ secrets.GCP_PROJECT_ID }}/php-app:${{ github.sha }} \
            --region ${{ secrets.GCP_REGION }} \
            --platform managed \
            --allow-unauthenticated \
            --set-env-vars ENV_VAR1=${{ secrets.ENV_VAR1 }},ENV_VAR2=${{ secrets.ENV_VAR2 }}

      # Step 7: Run Unit/Integration Tests
      - name: Run Unit/Integration Tests
        run: |
          docker run --rm gcr.io/${{ secrets.GCP_PROJECT_ID }}/php-app:${{ github.sha }} php vendor/bin/phpunit
     ## GitHub Secrets

Configure the following secrets in my GitHub repository settings:

- **`GCP_PROJECT_ID`**: Your Google Cloud project ID.
- **`GCP_SA_KEY`**: The JSON key for your Google Cloud service account.
- **`GCP_REGION`**: The region where you want to deploy your Cloud Run service.
- **`ENV_VAR1`, `ENV_VAR2`, etc.**: Any environment variables your PHP application requires.
