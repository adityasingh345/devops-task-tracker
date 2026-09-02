variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-west-2"
}

variable "instance_type" {
  default = "t3.micro"
}

variable "key_name" {
  description = "project"
  type        = string
}