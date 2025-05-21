resource "aws_route53_record" "app_dns" {
  zone_id = var.route53_zone_id
  name    = "${var.name_prefix}.${var.domain_name}"
  type    = "A"
  ttl     = "300"
  records = [var.ec2_public_ip]
}