resource "aws_lb" "main" {
  name                       = "${var.name}-alb-${var.environment}"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = var.alb_security_groups
  subnets                    = var.subnets.*.id
  drop_invalid_header_fields = true
  enable_deletion_protection = true

  tags = {
    Name   = "${var.name}-alb-${var.environment}"
    public = true
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_alb_target_group" "main" {
  name        = "${var.name}-tg-${var.environment}"
  port        = 8083
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    healthy_threshold   = "2"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200,301,302"
    timeout             = "10"
    path                = var.health_check_path
    unhealthy_threshold = "4"
  }

  tags = {
    Name = "${var.name}-tg-${var.environment}"
  }
}

# Redirect to https listener
resource "aws_alb_listener" "http" {
  load_balancer_arn = aws_lb.main.id
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.main.id
    type             = "forward"
  }

  tags = {
    Name = "${var.name}-http-${var.environment}"
  }
}

output "aws_alb_target_group_arn" {
  value = aws_alb_target_group.main.arn
}
