resource "aws_efs_file_system" "efs_calibre_web" {
  encrypted        = true
  performance_mode = "generalPurpose"

  creation_token = "${var.name}-config-${var.environment}"
  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }

  tags = {
    Name = "${var.name}-config-${var.environment}"
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_efs_file_system_policy" "efs_file_system_policy" {
  file_system_id = aws_efs_file_system.efs_calibre_web.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "elasticfilesystem:ClientRootAccess",
          "elasticfilesystem:ClientWrite"
        ]
        Effect = "Allow"
        Principal = {
          AWS = var.iam_efs_role_arn
        }
        Resource = aws_efs_file_system.efs_calibre_web.arn
        Condition = {
          Bool = {
            "elasticfilesystem:AccessedViaMountTarget" : "true"
          },
          Bool = {
            "aws:SecureTransport" : "true"
          },
        }
      },
    ]
  })
}

data "aws_iam_policy_document" "override_efs_access" {
  source_policy_documents = [var.inline_policy_efs_access]
  statement {
    sid = "AllowEFSAccess"
    actions = [
      "elasticfilesystem:ClientMount",
      "elasticfilesystem:ClientRootAccess"
    ]
    resources = [aws_efs_file_system.efs_calibre_web.arn]
  }
}

resource "aws_iam_role_policy" "efs_access" {
  name = "${var.name}-efs-access"
  role = var.iam_efs_role_name

  policy = data.aws_iam_policy_document.override_efs_access.json
}

resource "aws_efs_access_point" "efs_ap_config" {
  file_system_id = aws_efs_file_system.efs_calibre_web.id
  posix_user {
    gid = 1000
    uid = 1000
  }

  root_directory {
    path = "/config"
  }

  tags = {
    Name = "${var.name}-config-ap-${var.environment}"
  }
}

resource "aws_efs_access_point" "efs_ap_books" {
  file_system_id = aws_efs_file_system.efs_calibre_web.id
  posix_user {
    gid = 1000
    uid = 1000
  }
  root_directory {
    path = "/books"
  }

  tags = {
    Name = "${var.name}-books-ap-${var.environment}"
  }
}

resource "aws_efs_mount_target" "efs_mount_target_config" {
  count           = var.subnets_count
  file_system_id  = aws_efs_file_system.efs_calibre_web.id
  subnet_id       = element(var.private_subnets.*.id, count.index)
  security_groups = var.efs_security_groups
}

output "efs_id" {
  value = aws_efs_file_system.efs_calibre_web.id
}

output "efs_config_id" {
  value = aws_efs_access_point.efs_ap_config.id
}

output "efs_books_id" {
  value = aws_efs_access_point.efs_ap_books.id
}
