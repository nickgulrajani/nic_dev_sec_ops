#!/bin/bash

case "$1" in
  "up")
    echo "Creating infrastructure..."
    cd terraform
    terraform init
    terraform apply -var-file="environments/dev/terraform.tfvars" -auto-approve
    
    echo "Building and pushing container..."
    cd ../app
    az acr login --name acrdevopsdevng123
    docker build -t acrdevopsdevng123.azurecr.io/demo-app:latest .
    docker push acrdevopsdevng123.azurecr.io/demo-app:latest
    ;;

  "down")
    echo "Destroying infrastructure..."
    cd terraform
    terraform destroy -var-file="environments/dev/terraform.tfvars" -auto-approve
    ;;

  *)
    echo "Usage: $0 {up|down}"
    exit 1
    ;;
esac
