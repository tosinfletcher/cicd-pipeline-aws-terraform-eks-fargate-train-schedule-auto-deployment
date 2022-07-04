variable "region" {
  type    = string
  default = "us-east-1"
}

variable "cidr_block" {
  type    = string
  default = "10.0.0.0/16"
}

variable "cidr_public_subnet_1" {
  type    = string
  default = "10.0.1.0/24"
}

variable "cidr_public_subnet_2" {
  type    = string
  default = "10.0.2.0/24"
}

variable "cidr_public_subnet_3" {
  type    = string
  default = "10.0.3.0/24"
}

variable "cidr_private_subnet_1" {
  type    = string
  default = "10.0.4.0/24"
}

variable "cidr_private_subnet_2" {
  type    = string
  default = "10.0.5.0/24"
}

variable "cidr_private_subnet_3" {
  type    = string
  default = "10.0.6.0/24"
}


