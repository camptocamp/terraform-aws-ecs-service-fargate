resource "aws_ecs_service" "aws-ecs-service" {
  name                 = "${var.app_name}-${var.app_environment}-ecs-service"
  cluster              = var.ecs_cluster_id
  task_definition      = var.task_definition_revision != "" ? "${var.task_definition.family}:${var.task_definition.revision}" : "${var.task_definition.family}"
  launch_type          = "FARGATE"
  scheduling_strategy  = "REPLICA"
  desired_count        = var.task_desired_count
  force_new_deployment = true

  network_configuration {
    subnets          = var.generate_public_ip ? var.subnet_public_ids : var.subnet_private_ids
    assign_public_ip = var.generate_public_ip
    security_groups = [
      aws_security_group.service_security_group.id,
      aws_security_group.load_balancer_security_group.id
    ]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.target_group.arn
    container_name   = var.task_lb_container_name != "" ? var.task_lb_container_name : "${var.app_name}-${var.app_environment}-container"
    container_port   = var.task_lb_container_port
  }

  dynamic "service_registries" {
    for_each = var.service_registries
    content {
      registry_arn = service_registries.value["registry_arn"]
    }
  }

  depends_on = [aws_lb_listener.https_listener]
}

resource "aws_security_group" "service_security_group" {
  vpc_id = var.vpc_id

  ingress {
    from_port       = 0
    to_port         = 65535
    protocol        = "tcp"
    security_groups = [aws_security_group.load_balancer_security_group.id]
  }

  ingress {
    protocol    = "6"
    from_port   = 80
    to_port     = 8000
    cidr_blocks = [var.vpc_cidr_blocks]
  }

  ingress {
    from_port = 80
    to_port   = 80

    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name        = "${var.app_name}-service-sg"
    Environment = var.app_environment
  }
}

resource "aws_lb" "this" {
  name               = "${var.app_name}-${var.app_environment}"
  internal           = false
  load_balancer_type = "application"
  subnets            = var.subnet_public_ids
  security_groups    = [aws_security_group.load_balancer_security_group.id]

  tags = {
    Name        = "${var.app_name}-alb"
    Environment = var.app_environment
  }
}

resource "aws_security_group" "load_balancer_security_group" {
  vpc_id = var.vpc_id

  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  ingress {
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  tags = {
    Name        = "${var.app_name}-sg"
    Environment = var.app_environment
  }
}

resource "aws_lb_target_group" "target_group" {
  name        = "${var.app_name}-${var.app_environment}-tg"
  port        = var.task_lb_container_port
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  health_check {
    enabled = var.task_lb_healthcheck.enabled
    path    = var.task_lb_healthcheck.path
    port    = var.task_lb_healthcheck.port
    matcher = var.task_lb_healthcheck.matcher
  }

  tags = {
    Name        = "${var.app_name}-lb-tg"
    Environment = var.app_environment
  }
}

resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.this.id
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "https_listener" {
  load_balancer_arn = aws_lb.this.id
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = var.task_lb_custom_certificate_arn != "" ? var.task_lb_custom_certificate_arn : aws_acm_certificate_validation.alb_listener_cert_validation.0.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.id
  }
}
