resource "aws_acm_certificate" "alb_listener_cert" {
  domain_name       = "probe-1.eu-west-1.aws.probes.camptocamp.com"
  validation_method = "DNS"

  tags = {
    Name        = "${var.app_name}-lb-acm-cert"
    Environment = var.app_environment
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_lb.application_load_balancer
  ]
}

resource "aws_route53_record" "dns_record_validation" {
  for_each = {
    for dvo in aws_acm_certificate.alb_listener_cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.alb_dns_zone.zone_id
}

resource "aws_acm_certificate_validation" "alb_listener_cert_validation" {
  certificate_arn         = aws_acm_certificate.alb_listener_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.dns_record_validation : record.fqdn]
}
