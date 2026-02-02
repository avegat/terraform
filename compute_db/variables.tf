variable "aws_region" {}
variable "ami_id" {}
variable "instance_name" {}

variable "instance_type" {
  default = "t2.micro"
}

variable "vpc_id" {
  description = "ID de la VPC donde estará la base de datos"
  type        = string
}

variable "subnet_id" {
  description = "ID de la Subnet donde se creará la instancia"
  type        = string
}