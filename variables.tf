variable "region" {
  description = "The AWS region to deploy the resources in."
  type        = string
}

variable "profile" {
  description = "The AWS profile to use for authentication."
  type        = string
}

variable "environment" {
  description = "The environment for which the resources are being created (e.g., dev, prd)."
  type        = string
  validation {
    condition     = var.environment == "dev" || var.environment == "prd"
    error_message = "The environment must be either 'dev' or 'prd'."
  }
}
