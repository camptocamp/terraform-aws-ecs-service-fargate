data "aws_route53_zone" "alb_dns_zone" {
  count = var.dns_zone != "" ? 1 : 0

  name = var.dns_zone
}

resource "aws_route53_record" "alb_dns_record" {
  count = var.dns_host != "" ? 1 : 0

  zone_id = data.aws_route53_zone.alb_dns_zone.0.zone_id
  name    = var.dns_host
  type    = "A"

  alias {
    name                   = aws_lb.this.dns_name
    zone_id                = aws_lb.this.zone_id
    evaluate_target_health = true
  }
}
