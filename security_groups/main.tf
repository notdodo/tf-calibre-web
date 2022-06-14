resource "aws_security_group" "alb_sg" {
  name   = "${var.name}-sg-alb-${var.environment}"
  vpc_id = var.vpc_id
  # description = "Allow inbound Traffic from Internet to the container port on ECS cluster"
  ingress {
    description = "TCP from Cloudflare to exposed ALB port 80"
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = [
      "103.21.244.0/22",
      "103.22.200.0/22",
      "103.31.4.0/22",
      "104.16.0.0/13",
      "104.24.0.0/14",
      "108.162.192.0/18",
      "131.0.72.0/22",
      "141.101.64.0/18",
      "162.158.0.0/15",
      "172.64.0.0/13",
      "173.245.48.0/20",
      "188.114.96.0/20",
      "190.93.240.0/20",
      "197.234.240.0/22",
      "198.41.128.0/17"
    ]
    ipv6_cidr_blocks = [
      "2400:cb00::/32",
      "2606:4700::/32",
      "2803:f800::/32",
      "2405:b500::/32",
      "2405:8100::/32",
      "2a06:98c0::/29",
      "2c0f:f248::/32"
    ]
  }

  egress {
    description = "TCP to the exposed container port"
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
  # description = "Allow inbound traffic from the ALB and to internet for updates and fetch on ebook covers; additionally add NFS traffic to EFS security group to mount the volume"

  ingress {
    description     = "TCP from the exposed container port"
    protocol        = "tcp"
    from_port       = var.container_port
    to_port         = var.container_port
    prefix_list_ids = [aws_security_group.alb_sg.id]
  }

  egress {
    description      = "UDP to resolve external DNS names"
    protocol         = "udp"
    from_port        = 53
    to_port          = 53
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    description      = "TCP to fecth updates and book covers"
    protocol         = "tcp"
    from_port        = 80
    to_port          = 80
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    description      = "TCP to fecth updates and book covers"
    protocol         = "tcp"
    from_port        = 443
    to_port          = 443
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    description = "TCP to mount NFS volume"
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
  # description = "Only allow inbound traffic to mount the EFS volume from the ECS task"

  ingress {
    description     = "TCP to allow mount from ECS container task"
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
