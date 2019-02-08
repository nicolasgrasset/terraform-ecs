# outputs.tf

output "alb_hostname" {
  value = "${module.ecs-cluster.alb_dns_name}"
}