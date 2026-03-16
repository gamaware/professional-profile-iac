module "static_site" {
  source = "./modules/static-site"

  domain_name = var.domain_name

  providers = {
    aws           = aws
    aws.us_east_1 = aws.us_east_1
  }
}
