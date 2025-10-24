variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "ssh_user" {
  type    = string
  default = "ubuntu" # Ubuntu AMI
}

variable "ami_id" {
  type    = string
  # Ubuntu 20.04 LTS HVM (AMI varies by region) - override if needed
  default = ""
}
