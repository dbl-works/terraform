# resource "aws_lb" "nlb" {
#   count = 0 # TODO: Make this optional
#   name = "${local.name}-bastion"
#   load_balancer_type = "network"
#   subnets = var.subnet_public_ids
#   idle_timeout = 600
#   tags = {
#     Name = "${var.project}-${var.environment}-bastion"
#     Project = var.project
#     Environment = var.environment
#   }
# }

# # Bastion is allowed, only from some IPs
# resource "aws_lb_target_group" "bastion" {
#   name = "${var.project}-${var.environment}-bastion"
#   port = 22
#   protocol = "TCP"
#   vpc_id = var.vpc_id
#   target_type = "ip"
# }

# resource "aws_lb_listener" "ssh" {
#   load_balancer_arn = aws_lb.nlb.id
#   port = "22"
#   protocol = "TCP"

#   default_action {
#     target_group_arn = aws_lb_target_group.bastion.arn
#     type = "forward"
#   }
# }
