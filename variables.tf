variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "aws_profile" {
  description = "AWS CLI profile to use"
  type        = string
  default     = "personal"
}

variable "domain_name" {
  description = "Domain name for the website"
  type        = string
  default     = "alexgarcia.info"
}
