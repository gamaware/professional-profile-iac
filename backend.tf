# TODO: Configure remote state backend
# Uncomment and configure after creating the state bucket
#
# terraform {
#   backend "s3" {
#     bucket         = "gamaware-terraform-state"
#     key            = "professional-profile/terraform.tfstate"
#     region         = "us-east-1"
#     profile        = "personal"
#     encrypt        = true
#     dynamodb_table = "terraform-state-lock"
#   }
# }
