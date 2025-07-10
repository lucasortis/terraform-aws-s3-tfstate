#!/usr/bin/env bash

# This script runs Terraform commands for a specified environment.
# Usage: ./run-terraform.sh [-e=env|--env=env] [plan|apply]  

rm -rf .terraform

set -e

ENV="dev"  # Default environment
for arg in "$@"; do
  case $arg in
    -e=*|--env=*) ENV="${arg#*=}"; shift ;;
  esac
done

BASE="./environments/$ENV"
if [[ ! -d "$BASE" ]]; then
  echo "Environment '$ENV' does not exist."
  exit 1
fi

echo "Running Terraform $* for '$ENV'"

echo "Running 'terraform init' for '$ENV'"
  terraform init \
    -backend-config="$BASE/terraform.s3.tfbackend" \
    -upgrade \
    -reconfigure

if [ "$1" == "plan" ]; then
  echo "Running 'terraform plan' for '$ENV'"
  terraform plan -var-file="$BASE/terraform.tfvars" -out=tfplan
  exit 0
fi

if [ "$1" == "apply" ]; then
  echo "Running 'terraform apply' for '$ENV'"
  terraform apply tfplan
  exit 0
fi

if [ "$1" == "destroy" ]; then
  echo "Running 'terraform destroy' for '$ENV'"
  terraform destroy -var-file="$BASE/terraform.tfvars"
  exit 0
fi

  
  