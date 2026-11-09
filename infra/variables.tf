############################
# Général
############################
variable "aws_region" {
  description = "Région AWS (imposée par le Learner Lab)"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Préfixe utilisé pour nommer toutes les ressources"
  type        = string
  default     = "donatily"
}

variable "environment" {
  description = "dev ou prod (influence la capacité des ASG)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "environment doit valoir \"dev\" ou \"prod\"."
  }
}

############################
# Réseau
############################
variable "vpc_cidr" {
  description = "CIDR du VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "az_count" {
  description = "Nombre d'AZ utilisées (2 : AZ-a et AZ-b)"
  type        = number
  default     = 2
}

variable "public_subnet_cidrs" {
  description = "Sous-réseaux publics (ALB), un par AZ"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "frontend_subnet_cidrs" {
  description = "Sous-réseaux privés frontend, un par AZ"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24"]
}

variable "backend_subnet_cidrs" {
  description = "Sous-réseaux privés backend, un par AZ"
  type        = list(string)
  default     = ["10.0.21.0/24", "10.0.22.0/24"]
}

variable "db_subnet_cidrs" {
  description = "Sous-réseaux privés base de données, un par AZ (le DB subnet group RDS exige 2 AZ)"
  type        = list(string)
  default     = ["10.0.31.0/24", "10.0.32.0/24"]
}

variable "nat_mode" {
  description = "Mode NAT : seul 'regional' est supporté (1 NAT Gateway classique dans AZ-a, partagée par les instances backend)"
  type        = string
  default     = "regional"

  validation {
    condition     = var.nat_mode == "regional"
    error_message = "nat_mode doit valoir \"regional\" (NAT Gateway classique unique)."
  }
}

############################
# IAM (Learner Lab : rôles préexistants uniquement)
############################
variable "lab_instance_profile_name" {
  description = "Instance profile préexistant attaché aux EC2"
  type        = string
  default     = "LabInstanceProfile"
}

variable "key_name" {
  description = "Key pair EC2 optionnelle. Laisser vide : accès via SSM uniquement"
  type        = string
  default     = null
}

############################
# Compute / Auto Scaling
############################
variable "instance_type" {
  description = "Type d'instance des ASG frontend et backend"
  type        = string
  default     = "t2.micro"
}


############################
# Application (utilisé par user_data)
############################
variable "app_repo_url" {
  description = "URL Git du monorepo cloné par user_data"
  type        = string
  default     = ""
}
