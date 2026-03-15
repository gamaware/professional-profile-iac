terraform {
  backend "s3" {
    bucket       = "terraform-state-professional-profile-567209320893"
    key          = "website/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
