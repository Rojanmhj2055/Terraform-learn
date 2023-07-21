terraform {
  required_providers {
      aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
}

module "networking" {
  source = "./modules/networking"
  avail_zone = "us-west-1a"
  env_prefix = "DEV"
  subnet_cidr_blocks = ["10.0.0.0/19","10.0.32.0/19","10.0.64.0/19","10.0.96.0/19"]
}


module "EKS_Cluster" {
  source = "./modules/EKS"
  private-subnet-1-id = module.networking.private-subnet-1.id
  private-subnet-2-id = module.networking.private-subnet-2.id
  public-subnet-1-id = module.networking.public-subnet-1.id
  public-subnet-2-id = module.networking.public-subnet-2.id

depends_on = [ module.networking ]
  
}