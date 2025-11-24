#!/bin/bash

# LANC Azure Resource Setup Script
# Creates all necessary Azure resources for three-tier deployment

set -e

# Configuration
REPO_NAME="$1"
RESOURCE_GROUP="rg-lanc-${REPO_NAME}"
LOCATION="East US"
APP_SERVICE_PLAN="asp-lanc-${REPO_NAME}"

if [ -z "$REPO_NAME" ]; then
    echo "Usage: $0 <repository-name>"
    echo "Example: $0 my-service"
    exit 1
fi

echo "🚀 Creating Azure resources for LANC repository: $REPO_NAME"
echo "📍 Location: $LOCATION"
echo "📦 Resource Group: $RESOURCE_GROUP"

# Login check
echo "✅ Checking Azure login status..."
az account show > /dev/null || {
    echo "❌ Please login to Azure first: az login"
    exit 1
}

# Create Resource Group
echo "📦 Creating resource group..."
az group create \
    --name "$RESOURCE_GROUP" \
    --location "$LOCATION" \
    --tags "project=LANC" "repository=$REPO_NAME"

# Create App Service Plan (Free tier for development/staging, Basic for production)
echo "🏗️ Creating App Service Plan..."
az appservice plan create \
    --name "$APP_SERVICE_PLAN" \
    --resource-group "$RESOURCE_GROUP" \
    --location "$LOCATION" \
    --sku FREE \
    --is-linux

# Create Development App Service
echo "🔧 Creating Development App Service..."
az webapp create \
    --name "${REPO_NAME}-development" \
    --resource-group "$RESOURCE_GROUP" \
    --plan "$APP_SERVICE_PLAN" \
    --runtime "NODE:18-lts" \
    --startup-file "startup.sh"

# Create Staging App Service
echo "🧪 Creating Staging App Service..."
az webapp create \
    --name "${REPO_NAME}-staging" \
    --resource-group "$RESOURCE_GROUP" \
    --plan "$APP_SERVICE_PLAN" \
    --runtime "NODE:18-lts" \
    --startup-file "startup.sh"

# Create Production App Service (with custom domain ready)
echo "🚀 Creating Production App Service..."
az webapp create \
    --name "$REPO_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --plan "$APP_SERVICE_PLAN" \
    --runtime "NODE:18-lts" \
    --startup-file "startup.sh"

# Configure environment variables for all apps
echo "⚙️ Configuring environment variables..."

# Development environment
az webapp config appsettings set \
    --name "${REPO_NAME}-development" \
    --resource-group "$RESOURCE_GROUP" \
    --settings NODE_ENV=development PORT=8080 WEBSITE_NODE_DEFAULT_VERSION=18

# Staging environment
az webapp config appsettings set \
    --name "${REPO_NAME}-staging" \
    --resource-group "$RESOURCE_GROUP" \
    --settings NODE_ENV=staging PORT=8080 WEBSITE_NODE_DEFAULT_VERSION=18

# Production environment
az webapp config appsettings set \
    --name "$REPO_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --settings NODE_ENV=production PORT=8080 WEBSITE_NODE_DEFAULT_VERSION=18

# Configure health check endpoints for all apps
echo "🏥 Configuring health checks..."
for env in "development" "staging" ""; do
    if [ "$env" = "" ]; then
        app_name="$REPO_NAME"
    else
        app_name="${REPO_NAME}-${env}"
    fi
    
    az webapp config set \
        --name "$app_name" \
        --resource-group "$RESOURCE_GROUP" \
        --health-check-path "/health"
done

# Create GitHub deployment credentials (service principal)
echo "🔑 Creating GitHub deployment service principal..."
SUBSCRIPTION_ID=$(az account show --query id --output tsv)
SP_NAME="sp-github-${REPO_NAME}"

echo "⚠️  Creating service principal - credentials will be saved securely..."
SP_JSON=$(az ad sp create-for-rbac \
    --name "$SP_NAME" \
    --role contributor \
    --scopes "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP" \
    --sdk-auth)

# Save credentials to a secure temporary file
CREDENTIALS_FILE="/tmp/azure-credentials-${REPO_NAME}-$(date +%s).json"
echo "$SP_JSON" > "$CREDENTIALS_FILE"
chmod 600 "$CREDENTIALS_FILE"

echo "✅ Azure resources created successfully!"
echo ""
echo "📋 DEPLOYMENT INFORMATION:"
echo "Resource Group: $RESOURCE_GROUP"
echo "Development URL: https://${REPO_NAME}-development.azurewebsites.net"
echo "Staging URL: https://${REPO_NAME}-staging.azurewebsites.net"
echo "Production URL: https://${REPO_NAME}.azurewebsites.net"
echo ""
echo "🔑 GITHUB SECRETS TO ADD:"
echo "AZURE_CREDENTIALS: Saved securely to $CREDENTIALS_FILE"
echo "⚠️  IMPORTANT: Copy the contents of $CREDENTIALS_FILE to your GitHub repository secrets"
echo "⚠️  Then delete the file: rm $CREDENTIALS_FILE"
echo ""
echo "AZURE_RESOURCE_GROUP: $RESOURCE_GROUP"
echo "AZURE_WEBAPP_NAME_DEV: ${REPO_NAME}-development"
echo "AZURE_WEBAPP_NAME_STAGING: ${REPO_NAME}-staging"
echo "AZURE_WEBAPP_NAME_PROD: $REPO_NAME"
echo ""
echo "🎯 Next steps:"
echo "1. Copy contents of $CREDENTIALS_FILE to GitHub repository secrets as AZURE_CREDENTIALS"
echo "2. Add the other GitHub secrets listed above to your repository"
echo "3. Delete the credentials file: rm $CREDENTIALS_FILE"
echo "4. Push your code to trigger deployments"
echo "5. Visit the URLs above to verify deployment"