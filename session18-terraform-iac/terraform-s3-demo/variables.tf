variable "region" {
  type    = string
  default = "ap-south-1"
}
variable "bucket_name" {
  type = string
  validation {
    condition     = length(var.bucket_name) >= 3 && length(var.bucket_name) <= 63
    error_message = "Use a valid globally unique S3 bucket name."
  }
}
variable "environment" {
  type    = string
  default = "coursework"
}
