provider "aws" {
  region = var.region
}

module "network" {
  source = "./modules/network"
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
}

module "alb" {
  source = "./modules/alb"

  vpc_id         = module.network.vpc_id
  public_subnets = module.network.public_subnet_ids
  common_tags    = var.common_tags
}

module "compute" {
  source = "./modules/compute"

  vpc_id          = module.network.vpc_id
  private_subnets = module.network.private_subnet_ids
  tg_arn          = module.alb.tg_arn

  instance_type = var.instance_type
  key_name      = var.key_name
  user_data     = var.user_data

  bastion_sg_id = module.bastion.bastion_sg_id
  alb_sg_id     = module.alb.alb_sg_id
  common_tags   = var.common_tags
}
