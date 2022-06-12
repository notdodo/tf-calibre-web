resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.name}-ecsTaskExecutionRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role" "ecs_task_role" {
  name = "${var.name}-ecsTaskRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })
}

data "aws_iam_policy_document" "efs_access" {
  statement {
    sid = "AllowEFSAccess"
    actions = [
      "elasticfilesystem:ClientMount",
      "elasticfilesystem:ClientRootAccess"
    ]
    resources = ["*"] // This will be overwritten once the EFS volume is created
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy_attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# resource "aws_iam_role_policy_attachment" "ecs_task_role_policy_attachment" {
#   for_each = toset([
#     "arn:aws:iam::423779874966:policy/SSM-Messages-ecsTaskRole-exec" // To allow aws exec [optional]
#   ])

#   role       = aws_iam_role.ecs_task_role.name
#   policy_arn = each.value
# }


output "ecs_task_role_arn" {
  value = aws_iam_role.ecs_task_role.arn
}

output "ecs_task_role_name" {
  value = aws_iam_role.ecs_task_role.name
}

output "ecs_task_execution_role_arn" {
  value = aws_iam_role.ecs_task_execution_role.arn
}

output "inline_policy_efs_access" {
  value = data.aws_iam_policy_document.efs_access.json
}
