variable "name_prefix" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "azs" {
  description = "Liste des AZ (longueur = az_count)"
  type        = list(string)
}

variable "public_subnet_cidrs" {
  type = list(string)
}

variable "frontend_subnet_cidrs" {
  type = list(string)
}

variable "backend_subnet_cidrs" {
  type = list(string)
}

variable "db_subnet_cidrs" {
  type = list(string)
}
