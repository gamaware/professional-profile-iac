variable "domain_name" {
  description = "Domain name for the static site"
  type        = string
}

variable "index_document" {
  description = "Index document for S3 website hosting"
  type        = string
  default     = "index.html"
}

variable "error_document" {
  description = "Error document for S3 website hosting"
  type        = string
  default     = "error.html"
}
