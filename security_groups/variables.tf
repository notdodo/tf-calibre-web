variable "name" {
  description = "the name of the stack, e.g. \"demo\""
}

variable "environment" {
  description = "the name of the environment, e.g. \"prod\""
}

variable "vpc_id" {
  description = "The VPC ID"
}

variable "container_port" {
  description = "Ingres and egress port of the container"
}

variable "public_subnets" {
  description = "List of public subnets"
}

variable "private_subnets" {
  description = "List of private subnets"
}
