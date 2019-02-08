# ecs-cluster/main.tf

variable "namespace" {
  description = "Namespace of the cluster"
}

variable "aws_vpc_id" {
  description = "Security group id for network configuration"
}

variable "aws_subnet_id" {
  description = "Subnet id for network configuration"
  type = "list"
}

variable "aws_rds_security_group_id" {
  description = "Security group ID for RDS access"
}



resource "aws_ecs_cluster" "main" {
  name = "${var.namespace}-cluster"
}

# ALB Security Group: Edit this to restrict access to the application
resource "aws_security_group" "lb" {
  name        = "${var.namespace}-load-balancer-security-group"
  description = "controls access to the ALB"
  vpc_id      = "${var.aws_vpc_id}"

  ingress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# RDS access
resource "aws_security_group_rule" "rds_access" {
  type            = "ingress"
  from_port       = 3306
  to_port         = 3306
  protocol        = "tcp"
  source_security_group_id = "${aws_security_group.lb.id}"

  security_group_id = "${var.aws_rds_security_group_id}"
}

resource "aws_alb" "main" {
  name            = "${var.namespace}-load-balancer"
  subnets         = ["${var.aws_subnet_id}"]
  security_groups = ["${aws_security_group.lb.id}"]
}

resource "aws_service_discovery_private_dns_namespace" "namespace" {
  name        = "${var.namespace}.local"
  description = "${var.namespace} namespace"
  vpc         = "${var.aws_vpc_id}"
}


#
# Output
#


output "aws_ecs_cluster_id" {
  value = "${aws_ecs_cluster.main.id}"
}

output "aws_ecs_cluster_name" {
  value = "${aws_ecs_cluster.main.name}"
}

output "alb_dns_name" {
  value = "${aws_alb.main.dns_name}"
}

output "alb_zone_id" {
  value = "${aws_alb.main.zone_id}"
}

output "aws_alb_id" {
  value = "${aws_alb.main.id}"
}

output "aws_security_group_id" {
  value = "${aws_security_group.lb.id}"
}

output "aws_ecs_discover_namespace_id" {
  value = "${aws_service_discovery_private_dns_namespace.namespace.id}"
}