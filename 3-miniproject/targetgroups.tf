resource "aws_lb" "myaltelb" {
  name               = var.lb
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb-altsecuritygroup.id]
  subnets            = [for subnet in aws_subnet.altproject : subnet.id]

  tags = {
    Environment = "production"
  }
}

resource "aws_lb_target_group" "alttargetgroup" {
  name     = "alttargetgroup"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.altproject.id

  health_check {
    port     = 80
    protocol = "HTTP"
    path     = "/"
    matcher  = "200-299"
  }
}

resource "aws_lb_target_group_attachment" "test" {
  target_group_arn = aws_lb_target_group.alttargetgroup.arn
  target_id        = aws_instance.myinstance[each.key].id
  port             = 80
  for_each         = local.subnet_ids
}

resource "aws_lb_listener" "lb_listener_http" {
  load_balancer_arn = aws_lb.myaltelb.id
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.alttargetgroup.arn
    type             = "forward"
  }
}

resource "aws_route53_zone" "main" {
  name = var.domain["domain_name"]
}

resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.main.zone_id
  name    = var.domain["subdomain"]
  type    = "A"

  alias {
    name                   = aws_lb.myaltelb.dns_name
    zone_id                = aws_lb.myaltelb.zone_id
    evaluate_target_health = true
  }
}