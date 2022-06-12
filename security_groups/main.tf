resource "aws_security_group" "alb_sg" {
  name   = "${var.name}-sg-alb-${var.environment}"
  vpc_id = var.vpc_id
  ingress {
    protocol         = "tcp"
    from_port        = 80
    to_port          = 80
    cidr_blocks      = ["0.0.0.0/0"] // TODO: cloudflare
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    protocol    = "tcp"
    from_port   = var.container_port
    to_port     = var.container_port
    cidr_blocks = var.private_subnets
  }

  tags = {
    Name = "${var.name}-sg-alb-${var.environment}"
  }
}

resource "aws_security_group" "ecs_tasks_sg" {
  name   = "${var.name}-sg-task-${var.environment}"
  vpc_id = var.vpc_id

  ingress {
    protocol        = "tcp"
    from_port       = var.container_port
    to_port         = var.container_port
    prefix_list_ids = [aws_security_group.alb_sg.id]
  }

  egress {
    protocol         = "udp"
    from_port        = 53
    to_port          = 53
    cidr_blocks      = ["0.0.0.0/0"] // TODO
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    protocol         = "tcp"
    from_port        = 80
    to_port          = 80
    cidr_blocks      = ["0.0.0.0/0"] // TODO
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    protocol         = "tcp"
    from_port        = 443
    to_port          = 443
    cidr_blocks      = ["0.0.0.0/0"] // TODO
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    protocol    = "tcp"
    from_port   = 2049
    to_port     = 2049
    cidr_blocks = var.private_subnets
  }

  tags = {
    Name = "${var.name}-sg-task-${var.environment}"
  }
}

resource "aws_security_group" "efs_mount_sg" {
  name   = "${var.name}-efs-mount-${var.environment}"
  vpc_id = var.vpc_id

  ingress {
    protocol        = "tcp"
    from_port       = 2049
    to_port         = 2049
    prefix_list_ids = [aws_security_group.ecs_tasks_sg.id]
  }

  egress = []

  tags = {
    Name = "${var.name}-sg-efs-${var.environment}"
  }
}


output "alb_sg" {
  value = aws_security_group.alb_sg.id
}

output "ecs_tasks_sg" {
  value = aws_security_group.ecs_tasks_sg.id
}

output "efs_sg" {
  value = aws_security_group.efs_mount_sg.id
}
