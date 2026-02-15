provider "aws" {
  region = var.region
}

module "network" {
  source = "./modules/network"

  vpc_cidr      = var.vpc_cidr
  public_cidrs  = var.public_cidrs
  private_cidrs = var.private_cidrs
  common_tags   = var.common_tags
}

module "bastion" {
  source = "./modules/bastion"

  vpc_id           = module.network.vpc_id
  public_subnet_id = module.network.public_subnet_ids[0]

  ami_id        = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name
  ssh_cidr      = var.ssh_cidr
  common_tags   = var.common_tags
  ssh_key_path  = var.ssh_key_path
}

module "alb" {
  source = "./modules/alb"

  vpc_id         = module.network.vpc_id
  public_subnets = module.network.public_subnet_ids
  common_tags    = var.common_tags
  alb_name       = var.alb_name
  alb_port       = var.alb_port
  app_port       = var.app_port
}

module "compute" {
  source = "./modules/compute"

  vpc_id          = module.network.vpc_id
  private_subnets = module.network.private_subnet_ids
  tg_arn          = module.alb.tg_arn

  instance_type = var.instance_type
  key_name      = var.key_name
  user_data     = var.user_data
  app_port      = var.app_port

  bastion_sg_id = module.bastion.bastion_sg_id
  alb_sg_id     = module.alb.alb_sg_id
  common_tags   = var.common_tags
  asg_name      = var.asg_name
}
