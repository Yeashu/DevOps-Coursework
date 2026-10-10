variable "region" {
  type    = string
  default = "ap-south-1"
}
variable "name" {
  type    = string
  default = "coursework"
}
variable "vpc_cidr" {
  type    = string
  default = "10.42.0.0/16"
}
variable "subnet_cidr" {
  type    = string
  default = "10.42.1.0/24"
}
variable "ami_id" {
  type = string
}
variable "bucket_name" {
  type = string
}
