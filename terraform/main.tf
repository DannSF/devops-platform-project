module "network" {
  source = "./modules/network"

  aws_region   = var.aws_region
  project_name = var.project_name
}

module "eks" {
  source = "./modules/eks"

  project_name      = var.project_name
  subnet_ids        = module.network.public_subnet_ids
  node_desired_size = var.node_desired_size
  node_min_size     = var.node_min_size
  node_max_size     = var.node_max_size
}

module "github_oidc" {
  source = "./modules/github-oidc"

  project_name        = var.project_name
  cluster_name        = module.eks.cluster_name
  cluster_arn         = module.eks.cluster_arn
  github_oidc_subject = var.github_oidc_subject
  eks_namespace       = "default"
}
