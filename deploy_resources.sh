#!/usr/bin/env bash

echo "Downloading and updating modules..."
terraform get -update

echo "Creating targeted infrastructure plan for the rest of the modules"
terraform plan -var-file=terraform.tfvars -out="main.tfplan" -target=module.ec2 -target=module.acm -target=module.security -target=module.route53

read -e -p "Apply the Terraform plan? [Y/N] " YN
[[ $YN == "y" || $YN == "Y" ]] || { echo "Operation cancelled"; exit 0; }

echo "Applying infrastructure plan..."
terraform apply "main.tfplan"