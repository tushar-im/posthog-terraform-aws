#!/usr/bin/env bash
set -e

echo "Setting up Terraform backend"
echo "Downloading and updating modules..."
terraform get -update

echo "Initializing Terraform without backend..."
terraform init -backend=false

echo "Creating plan for backend resources..."
terraform plan -var-file="terraform.tfvars" -out="backend.tfplan" -target=module.backend

read -e -p "Apply the Terraform plan to create backend resources? [Y/N] " YN
[[ $YN == "y" || $YN == "Y" ]] || { echo "Operation cancelled"; exit 0; }


echo "Applying backend infrastructure plan..."

terraform apply "backend.tfplan"

echo "Waiting for backend resources to be fully available..."
sleep 10

echo "Reinitializing Terraform with the new backend..."
terraform init -reconfigure -force-copy

echo "Backend setup complete!"
echo "You can now run 'terraform plan -var-file=<env>.tfvars' and 'terraform apply -var-file=<env>.tfvars'."