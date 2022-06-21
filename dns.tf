data "aws_route53_zone" "alb_dns_zone" {
  name = var.dns_zone
}

resource "aws_route53_record" "alb_dns_record" {
  zone_id = data.aws_route53_zone.alb_dns_zone.zone_id
  name    = var.dns_host
  type    = "A"

  alias {
    name                   = aws_lb.application_load_balancer.dns_name
    zone_id                = aws_lb.application_load_balancer.zone_id
    evaluate_target_health = true
  }
}
