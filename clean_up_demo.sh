#!/bin/bash

echo "🧹 Starting comprehensive cleanup..."

# Set your subscription ID
SUBSCRIPTION_ID="cd44851d-95f9-47eb-8074-605552aa6953"
RESOURCE_GROUP="rg-devops-dev"
ACR_NAME="acrdevopsdevng123"

echo "📋 Using:"
echo "   Subscription: $SUBSCRIPTION_ID"
echo "   Resource Group: $RESOURCE_GROUP"
echo "   ACR Name: $ACR_NAME"

# Function to check if a command succeeded
check_status() {
    if [ $? -eq 0 ]; then
        echo "✅ Success: $1"
    else
        echo "❌ Failed: $1"
    fi
}

# 1. First try terraform destroy
echo "🔧 Attempting Terraform destroy..."
cd terraform
terraform destroy -var-file="environments/dev/terraform.tfvars" -auto-approve
check_status "Terraform destroy"

# 2. Clean up Container Apps
echo "🗑️ Cleaning up Container Apps..."
az containerapp delete --name app-devops-dev --resource-group $RESOURCE_GROUP --yes 2>/dev/null
check_status "Container Apps cleanup"

# 3. Clean up ACR and images
echo "🗑️ Cleaning up Azure Container Registry..."
# List and remove all images
for repo in $(az acr repository list -n $ACR_NAME --output tsv 2>/dev/null); do
    echo "   Deleting repository: $repo"
    az acr repository delete --name $ACR_NAME --repository $repo --yes 2>/dev/null
done
check_status "ACR repositories cleanup"

# 4. Clean up local Docker images
echo "🗑️ Cleaning up local Docker images..."
# Remove specific images
docker rmi -f $(docker images "$ACR_NAME.azurecr.io/*" -q) 2>/dev/null
check_status "Local Docker images cleanup"

# 5. Delete the resource group (this will delete everything in it)
echo "🗑️ Deleting resource group..."
az group delete --name $RESOURCE_GROUP --yes --no-wait
check_status "Resource group deletion initiated"

# 6. Clean up terraform state
echo "🧹 Cleaning up Terraform state..."
rm -rf .terraform .terraform.lock.hcl terraform.tfstate terraform.tfstate.backup 2>/dev/null
check_status "Terraform state cleanup"

# 7. Logout from ACR
echo "🔒 Logging out from ACR..."
az acr logout --name $ACR_NAME 2>/dev/null
check_status "ACR logout"

echo "
🎉 Cleanup Summary:
- Terraform resources destroyed
- Container Apps removed
- ACR images deleted
- Local Docker images cleaned
- Resource group deletion initiated
- Terraform state cleaned
- ACR logged out

Note: Resource group deletion happens asynchronously and may take a few minutes to complete.
You can check the status with: az group show -n $RESOURCE_GROUP"

# Optional: Verify resource group deletion
echo "
🔍 Verifying resource group deletion..."
sleep 10  # Wait a bit before checking
if az group show -n $RESOURCE_GROUP &>/dev/null; then
    echo "⏳ Resource group deletion in progress... This may take a few minutes."
else
    echo "✅ Resource group deleted successfully!"
fi
