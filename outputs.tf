output "alb_dns_name" {
  value = aws_lb.this.dns_name
}

output "alb_security_group_id" {
  value = aws_security_group.load_balancer_security_group.id
}

output "service_security_group_id" {
  value = aws_security_group.service_security_group.id
}

output "alb_https_listener_arn" {
  value = aws_lb_listener.https_listener.arn
}
