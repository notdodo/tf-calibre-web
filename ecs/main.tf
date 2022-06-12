resource "aws_cloudwatch_log_group" "main" {
  name = "/ecs/${var.name}-lg-${var.environment}"

  tags = {
    Name = "${var.name}-log-${var.environment}"
  }
}

resource "aws_ecs_task_definition" "main" {
  family                   = "${var.name}-task-${var.environment}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.container_cpu
  memory                   = var.container_memory
  execution_role_arn       = var.task_execution_role
  task_role_arn            = var.task_role
  container_definitions = jsonencode([{
    name        = "${var.name}-container-${var.environment}"
    image       = "${var.container_image}"
    essential   = true
    environment = var.container_environment
    portMappings = [{
      protocol      = "tcp"
      containerPort = var.container_port
      hostPort      = var.container_port
    }]
    command = []
    mountPoints = [
      {
        containerPath = "/books"
        sourceVolume  = "books"
      },
      {
        containerPath = "/config"
        sourceVolume  = "config"
    }, ]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.main.name
        awslogs-stream-prefix = "ecs"
        awslogs-region        = var.region
      }
    }
  }])

  volume {
    name = "config"
    efs_volume_configuration {
      file_system_id     = var.container_volume
      transit_encryption = "ENABLED"
      authorization_config {
        access_point_id = var.container_volume_config
        iam             = "ENABLED"
      }
    }
  }

  volume {
    name = "books"
    efs_volume_configuration {
      file_system_id     = var.container_volume
      transit_encryption = "ENABLED"
      authorization_config {
        access_point_id = var.container_volume_books
        iam             = "ENABLED"
      }
    }
  }

  tags = {
    Name = "${var.name}-task-${var.environment}"
  }
}

resource "aws_ecs_cluster" "main" {
  name = "${var.name}-cluster-${var.environment}"
  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Name = "${var.name}-cluster-${var.environment}"
  }
}

resource "aws_ecs_service" "main" {
  name                              = "${var.name}-service-${var.environment}"
  cluster                           = aws_ecs_cluster.main.id
  task_definition                   = aws_ecs_task_definition.main.arn
  desired_count                     = var.service_desired_count
  health_check_grace_period_seconds = 60
  launch_type                       = "FARGATE"
  scheduling_strategy               = "REPLICA"
  enable_execute_command            = true

  network_configuration {
    security_groups  = var.ecs_service_security_groups
    subnets          = var.subnets.*.id
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.aws_alb_target_group_arn
    container_name   = "${var.name}-container-${var.environment}"
    container_port   = var.container_port
  }

  tags = {
    Name = "${var.name}-service-${var.environment}"
  }
}
