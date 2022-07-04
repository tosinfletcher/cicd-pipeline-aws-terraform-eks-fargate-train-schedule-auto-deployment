resource "aws_acm_certificate" "tfletcher_cert" {
  domain_name       = "train-schedule.tosinfletcher.com"
  validation_method = "DNS"

  tags = {
    Name = "tfletcher_cert"
  }

  lifecycle {
    create_before_destroy = true
  }
}
