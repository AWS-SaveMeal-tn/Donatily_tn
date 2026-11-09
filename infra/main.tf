module "vpc" {
  source = "./modules/vpc"

  name_prefix           = local.name_prefix
  vpc_cidr              = var.vpc_cidr
  azs                   = local.azs
  public_subnet_cidrs   = var.public_subnet_cidrs
  frontend_subnet_cidrs = var.frontend_subnet_cidrs
  backend_subnet_cidrs  = var.backend_subnet_cidrs
  db_subnet_cidrs       = var.db_subnet_cidrs
}

module "security_groups" {
  source = "./modules/security_groups"

  name_prefix = local.name_prefix
  vpc_id      = module.vpc.vpc_id
  vpc_cidr    = var.vpc_cidr
}

module "app_instance" {
  source = "./modules/compute_app"

  name_prefix           = local.name_prefix
  subnet_id             = module.vpc.frontend_subnet_ids[0]
  security_group_id     = module.security_groups.frontend_sg_id
  instance_type         = var.instance_type
  instance_profile_name = var.lab_instance_profile_name
  key_name              = var.key_name
  app_repo_url          = var.app_repo_url
}
