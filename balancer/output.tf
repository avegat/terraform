output "target_group_arn" { value = aws_lb_target_group.nginx_tg.arn }
output "lb_security_group_id" { value = aws_security_group.lb_sg.id }
output "lb_dns_name" { value = aws_lb.app_lb.dns_name }