variable "vpc_cidr" {}

variable "public_subnet" {
  type = "list"
}

variable "external_subnet" {
  type = "list"
}

variable "internal_subnet" {
  type = "list"
}


variable "public_availability_zone" {
  type = "list"
}

variable "external_availability_zone" {
  type = "list"
}

variable "internal_availability_zone" {
  type = "list"
}


variable "vpc_tag" {}

variable "igw_tag" {}

variable "public_subnet_tag" {
  type = "list"
}

variable "external_subnet_tag" {
  type = "list"
}

variable "internal_subnet_tag" {
  type = "list"
}


variable "public_rt_name" {}

variable "external_rt_name" {}

variable "internal_rt_name" {}

variable "region" {}
