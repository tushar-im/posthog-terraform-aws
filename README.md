# posthog-terraform-aws

## Instructions

1. Make sure you to not run `terraform init` in this directory.

2. Run `bash create_backend.sh` to create the backend.

```
bash create_backend.sh
```

```
Setting up Terraform backend
Downloading and updating modules...
- acm in modules/acm
- backend in modules/backend
- ec2 in modules/ec2
- route53 in modules/route53
- security in modules/security
Initializing Terraform without backend...
Initializing modules...

Initializing provider plugins...
- Finding latest version of hashicorp/aws...
- Finding latest version of hashicorp/local...
- Installing hashicorp/aws v5.98.0...
- Installed hashicorp/aws v5.98.0 (signed by HashiCorp)
- Installing hashicorp/local v2.5.3...
- Installed hashicorp/local v2.5.3 (signed by HashiCorp)

Terraform has created a lock file .terraform.lock.hcl to record the provider
selections it made above. Include this file in your version control repository
so that Terraform can guarantee to make the same selections by default when
you run "terraform init" in the future.

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
Creating plan for backend resources...
```

Terraform will create the following resources:

   - **S3 Bucket for Terraform State** (`aws_s3_bucket.tfstate`)
      - Bucket name: `posthog-production-tfstate`
      - Tagged with Environment: `production`, Project: `posthog`

   - **S3 Bucket Policy** (`aws_s3_bucket_policy.tfstate`)
      - Applies access policies to the state bucket

   - **Public Access Block** (`aws_s3_bucket_public_access_block.tfstate`)
      - Blocks all public access to the bucket
      - Ensures the state remains private and secure

   - **Server-Side Encryption** (`aws_s3_bucket_server_side_encryption_configuration.tfstate_bucket_encryption`)
      - Enables AES256 encryption for all objects in the bucket

   - **Bucket Versioning** (`aws_s3_bucket_versioning.tfstate_versioning`)
      - Enables versioning to maintain history of state files

   - **Local Backend Configuration File** (`local_file.key`)
      - Creates a `backend.tf` file with the necessary configuration

The backend setup creates a total of 6 resources to establish a secure, encrypted, and versioned S3 bucket for storing Terraform state files.

3. After creating the backend, deploy the remaining infrastructure resources by running:

```
bash deploy_resources.sh
```

This script will create the following resources:

   - **ACM Certificate** (`module.acm.aws_acm_certificate.ssl_certificate`)
      - Domain: `posthog.<domain_name>`
      - Validation method: DNS
      - Tagged with Environment: `production`, Name: `posthog-certificate`

   - **Certificate Validation** (`module.acm.aws_acm_certificate_validation.ssl_cert_validation`)
      - Validates the SSL certificate for use with AWS services

   - **DNS Validation Records** (`module.acm.aws_route53_record.cert_validation`)
      - Creates DNS records required for certificate validation

   - **EC2 Instance** (`module.ec2.aws_instance.app_server`)
      - Instance type: `t3.xlarge`
      - AMI: `ami-04999cd8f2624f834`
      - Root volume: 30GB gp3 (encrypted)
      - SSH key: `posthog-production-ec2-key`
      - **Automated PostHog Installation**: The EC2 instance automatically installs and configures PostHog during provisioning

   - **Elastic IP** (`module.ec2.aws_eip.instance_eip`)
      - Provides a static public IP for the EC2 instance
      - Tagged with Environment: `production`, Name: `posthog-eip`

   - **EIP Association** (`module.ec2.aws_eip_association.eip_assoc`)
      - Associates the Elastic IP with the EC2 instance

   - **SSH Key Pair** (`module.ec2.aws_key_pair.ec2_key_pair`)
      - Creates an SSH key pair for secure access to the EC2 instance
      - Key name: `posthog-production-ec2-key`

   - **TLS Private Key** (`module.ec2.tls_private_key.instance_public_key`)
      - Generates a 4096-bit RSA key pair for SSH access

   - **DNS Record** (`module.route53.aws_route53_record.app_dns`)
      - Creates an A record pointing to the EC2 instance
      - Domain: `posthog.<domain_name>`

   - **Security Group** (`module.security.aws_security_group.main`)
      - Allows inbound traffic on ports 22 (SSH), 80 (HTTP), and 443 (HTTPS)
      - Allows all outbound traffic
      - Tagged with Environment: `production`, Name: `posthog-sg`

4. After deployment completes, you can access your PostHog instance at `https://posthog.<domain_name>` once DNS propagation is complete.

5. The EC2 public IP address will be displayed in the output for direct access if needed.

## Post-Deployment Steps

1. **SSH Access to EC2 Instance** (if needed for troubleshooting):
   - The private key for SSH access is generated during deployment
   - Check your Terraform output for the location of the saved private key file
   - Use the following command to connect to your instance:
   ```
   ssh -i /path/to/private/key.pem ubuntu@posthog.<domain_name>
   ```

2. **PostHog Initial Setup**:
   - Navigate to `https://posthog.<domain_name>` in your browser
   - Follow the on-screen instructions to complete the PostHog setup
   - Create your admin account and set up your first project
   - Note: It may take 5-10 minutes after deployment for PostHog to be fully operational

3. **SSL Certificate Validation**:
   - The ACM certificate validation happens automatically via DNS
   - Certificate validation may take up to 30 minutes to complete
   - You can check the status in the AWS ACM console

4. **Backup and Maintenance**:
   - Set up regular backups of your PostHog data
   - Monitor instance performance and scale resources as needed
   - Keep the system updated with security patches

## Troubleshooting

- **DNS Issues**: If you cannot access the PostHog instance via the domain name, check:
  - DNS propagation (can take up to 48 hours)
  - Route53 record configuration
  - Security group rules

- **SSL Certificate Problems**: If you see certificate warnings:
  - Verify the certificate has been validated in ACM
  - Check that the domain name matches exactly what's in the certificate

- **EC2 Connection Issues**: If you cannot connect to the EC2 instance:
  - Verify the security group allows SSH access from your IP
  - Check that you're using the correct private key
  - Ensure the instance is running

- **PostHog Installation Issues**: If PostHog isn't working properly:
  - SSH into the EC2 instance
  - Check Docker logs with `docker-compose logs`
  - Verify all containers are running with `docker-compose ps`
  - Check system resources with `top` or `htop` to ensure sufficient memory
  - If Posthog installation was not done successfully run the following command which will spin up a fresh PostHog deployment. [See more here](https://posthog.com/docs/self-host#setting-up-the-stack)
      ```bash
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/posthog/posthog/HEAD/bin/deploy-hobby)"
      ```


## Infrastructure Maintenance

To update or modify your infrastructure:

1. Make changes to the Terraform configuration files
2. Run `terraform plan` to preview changes
3. Apply changes with `terraform apply`

To destroy the infrastructure when no longer needed:

```
terraform destroy -var-file=terraform.tfvars
```

**Note**: This will permanently delete all resources. Make sure to back up any important data before destroying the infrastructure.
