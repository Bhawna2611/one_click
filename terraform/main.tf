provider "aws" {
  region = "us-east-1"
}

module "network" {
  source = "./modules/network"
}

module "compute" {
  source            = "./modules/compute"
  vpc_id            = module.network.vpc_id
  public_subnet_id  = module.network.public_subnet_ids[0]
  private_subnet_id = module.network.private_subnet_ids[0]
}


