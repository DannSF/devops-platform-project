module "network" {
  source = "./modules/network"

  aws_region   = var.aws_region
  project_name = var.project_name
}

module "eks" {
  source = "./modules/eks"

  subnet_ids        = module.network.public_subnet_ids
  project_name      = var.project_name
  node_desired_size = var.node_desired_size
  node_min_size     = var.node_min_size
  node_max_size     = var.node_max_size
}
