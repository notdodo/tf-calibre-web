variable "name" {
  description = "the name of the stack, e.g. \"demo\""
}

variable "environment" {
  description = "the name of the environment, e.g. \"prod\""
}

variable "public_subnets" {
  description = "Comma separated list of public subnets IDs"
}

variable "efs_security_groups" {
  description = "Security Groups for EFS"
}

variable "iam_efs_role_arn" {
  description = "ARN of the IAM role allowed to access the EFS"
}

variable "iam_efs_role_name" {
  description = "Name of the IAM role allowed to access the EFS"
}

variable "inline_policy_efs_access" {
  description = "JSON of the inline policy for the ECS Task Role to access EFS"
  type        = string
}
