output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnet_ids" {
  value = module.vpc.public_subnet_ids
}

output "frontend_subnet_ids" {
  value = module.vpc.frontend_subnet_ids
}

output "backend_subnet_ids" {
  value = module.vpc.backend_subnet_ids
}

output "db_subnet_ids" {
  value = module.vpc.db_subnet_ids
}

output "nat_gateway_id" {
  description = "ID de la NAT Gateway classique"
  value       = module.vpc.nat_gateway_id
}

output "security_group_ids" {
  value = {
    alb      = module.security_groups.alb_sg_id
    frontend = module.security_groups.frontend_sg_id
    backend  = module.security_groups.backend_sg_id
    db       = module.security_groups.db_sg_id
  }
}

output "app_instance_id" {
  value = module.app_instance.instance_id
}

output "app_instance_private_ip" {
  value = module.app_instance.private_ip
}

output "ssm_connect" {
  description = "Commande pour ouvrir un shell SSM sur l'instance privée"
  value       = "aws ssm start-session --target ${module.app_instance.instance_id} --region ${var.aws_region}"
}
