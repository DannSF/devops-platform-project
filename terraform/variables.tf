variable "aws_region" {
  description = "AWS region used by the project"
  type        = string
  default     = "ap-southeast-2"
}

variable "project_name" {
  description = "Name used to identify project resources"
  type        = string
  default     = "devops-platform"
}

variable "node_instance_type" {
  description = "EC2 instance type used by the EKS managed node group"
  type        = string
  default     = "t3.small"
}

variable "node_desired_size" {
  description = "Desired number of EKS worker nodes"
  type        = number
  default     = 1
}

variable "node_min_size" {
  description = "Minimum number of EKS worker nodes"
  type        = number
  default     = 1
}

variable "node_max_size" {
  description = "Maximum number of EKS worker nodes"
  type        = number
  default     = 2
}
