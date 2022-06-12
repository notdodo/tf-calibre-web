variable "name" {
  description = "the name of the stack, e.g. \"demo\""
}

variable "environment" {
  description = "the name of the environment, e.g. \"prod\""
}

variable "region" {
  description = "the AWS region in which resources are created"
}

variable "subnets" {
  description = "List of subnet IDs"
}

variable "ecs_service_security_groups" {
  description = "Comma separated list of security groups"
}

variable "container_port" {
  description = "Port of container"
}

variable "container_cpu" {
  description = "The number of cpu units used by the task"
}

variable "container_memory" {
  description = "The amount (in MiB) of memory used by the task"
}

variable "container_image" {
  description = "Docker image to be launched"
}

variable "container_volume_config" {
  description = "AP ID of the volume to mount in the container /config"
}

variable "container_volume_books" {
  description = "AP ID of the volume to mount in the container /books"
}


variable "container_volume" {
  description = "EFS ID of the volume to mount in the container"
}

variable "aws_alb_target_group_arn" {
  description = "ARN of the alb target group"
}

variable "service_desired_count" {
  description = "Number of services running in parallel"
}

variable "container_environment" {
  description = "The container environmnent variables"
  type        = list(any)
}

variable "task_execution_role" {
  description = "The task execution IAM role ARN"
  type        = string
}

variable "task_role" {
  description = "The task IAM role ARN"
  type        = string
}
