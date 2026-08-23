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
