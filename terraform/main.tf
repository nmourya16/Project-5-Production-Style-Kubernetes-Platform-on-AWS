module "vpc" {
  source = "./modules/vpc"

  vpc_cidr             = "10.50.0.0/16"
  availability_zones   = ["eu-north-1a", "eu-north-1b"]
  public_subnet_cidrs  = ["10.50.1.0/24", "10.50.2.0/24"]
  private_subnet_cidrs = ["10.50.11.0/24", "10.50.12.0/24"]
  project_name         = "project5"
}

module "eks" {
  source = "./modules/eks"

  cluster_name       = "project5-eks"
  kubernetes_version = "1.33"
  private_subnet_ids = module.vpc.private_subnet_ids
  project_name       = "project5"

  node_instance_types = ["t3.small"]
  node_min_size       = 2
  node_desired_size   = 2
  node_max_size       = 3
}