# Terraform AWS S3 Remote State Backend Setup
*This README was created using Claude Sonnet 4 through GitHub Copilot and revised by me.*

This project creates an S3 bucket to store Terraform state files. Run this first if you don't already have an S3 bucket configured for remote state storage.

## Prerequisites

- AWS CLI configured
- Terraform >= 1.12.0
- AWS profile configured

## Project Structure

```
├── main.tf                           # Main Terraform configuration
├── variables.tf                      # Variable definitions
├── versions.tf                       # Provider and version constraints
├── output.tf                         # Output definitions
├── terraform-helper.sh               # Helper script for environment-specific operations
├── .pre-commit-config.yaml           # Pre-commit hooks configuration
└── environments/
    ├── dev/
    │   ├── terraform.tfvars          # Development environment variables
    │   └── terraform.s3.tfbackend    # S3 backend configuration (to be populated)
    └── prd/
        ├── terraform.tfvars          # Production environment variables
        └── terraform.s3.tfbackend    # S3 backend configuration (to be populated)
```

## Pre-commit Hooks (Optional)

This project includes pre-commit hooks for code quality:
```bash
# Install pre-commit
pip install pre-commit

# Install hooks
pre-commit install

# Run manually (optional - hooks run automatically on commit)
pre-commit run --all-files
```

The configuration includes:
- `terraform_fmt`: Formats Terraform code
- `terraform_validate`: Validates Terraform configuration

## Setup Instructions

### 1. Plan and Apply (Local State)
Replace `<env>` with `dev` or `prd`:
```bash
./terraform-helper.sh --env=<env> plan
./terraform-helper.sh --env=<env> apply
```

### 2. Update Backend Configuration
Copy the `s3_bucket_name` output and update `./environments/<env>/terraform.s3.tfbackend`:
```
bucket       = "lortis-abc12345-dev"  # <- Replace with actual bucket name
key          = "s3-tfstate/terraform.tfstate"
region       = "us-east-1"
profile      = "personal"
use_lockfile = true
```

### 3. Enable S3 Backend
Uncomment this line in `versions.tf`:
```terraform
terraform {
  ... 
  #backend "s3" {} <- Uncomment this
}
```
Note: Comment this line again and repeat steps 1, 2, and 3 to create the S3 bucket for the production environment.

### 4. Migrate State to S3
The terraform will automatically detect the backend configuration and prompt for migration (When prompted, enter 'yes' to migrate the statefile):
```bash
./terraform-helper.sh --env=<env> plan
```

#### Expected Output
```
Running Terraform plan for 'dev'
Running 'terraform init' for 'dev'

Initializing the backend...
Do you want to copy existing state to the new backend?
  Pre-existing state was found while migrating the previous "local" backend to the
  newly configured "s3" backend. No existing state was found in the newly
  configured "s3" backend. Do you want to copy this state to the new "s3"
  backend? Enter "yes" to copy and "no" to start with an empty state.

  Enter a value: yes

Successfully configured the backend "s3"! Terraform will automatically
use this backend unless the backend configuration changes.

Initializing provider plugins...
- Reusing previous version of hashicorp/aws from the dependency lock file
- Reusing previous version of hashicorp/random from the dependency lock file
- Using previously-installed hashicorp/aws v6.x.x
- Using previously-installed hashicorp/random v3.x.x

Terraform has been successfully initialized!

Running 'terraform plan' for 'dev'
random_string.random_suffix: Refreshing state... [id=abc12345]
aws_s3_bucket.remote_backend: Refreshing state... [id=lortis-abc12345-dev]
aws_s3_bucket_ownership_controls.remote_backend: Refreshing state... [id=lortis-abc12345-dev]
aws_s3_bucket_acl.remote_backend: Refreshing state... [id=lortis-abc12345-dev,private]
aws_s3_bucket_versioning.remote_backend: Refreshing state... [id=lortis-abc12345-dev]
aws_s3_bucket_public_access_block.remote_backend: Refreshing state... [id=lortis-abc12345-dev]
aws_s3_bucket_policy.remote_backend: Refreshing state... [id=lortis-abc12345-dev]
aws_s3_bucket_object_lock_configuration.remote_backend: Refreshing state... [id=lortis-abc12345-dev]

No changes. Your infrastructure matches the configuration.

Terraform has compared your real infrastructure against your configuration
and found no differences, so no changes are needed.
```

## Using the Helper Script

The `terraform-helper.sh` script automatically runs `terraform init` with backend configuration before any command:

```bash
# Plan for specific environment (includes init)
./terraform-helper.sh --env=dev plan

# Apply for specific environment (includes init)
./terraform-helper.sh --env=dev apply

# Use default environment (dev) if no --env specified
./terraform-helper.sh plan
./terraform-helper.sh apply
```

**Note**: 
- The script always runs `terraform init` with `-backend-config`, `-upgrade`, and `-reconfigure` flags
- Default environment is `dev` if `--env` is not specified

## Environment Configuration

### Development Environment
- File: `environments/dev/terraform.tfvars`
- Region: us-east-1
- Profile: personal
- Environment: dev

### Production Environment
- File: `environments/prd/terraform.tfvars`
- Region: us-east-1
- Profile: personal
- Environment: prd

