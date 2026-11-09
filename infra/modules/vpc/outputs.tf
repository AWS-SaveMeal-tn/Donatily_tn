output "vpc_id" {
  value = aws_vpc.this.id
}

output "vpc_cidr" {
  value = aws_vpc.this.cidr_block
}

output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}

output "frontend_subnet_ids" {
  value = aws_subnet.frontend[*].id
}

output "backend_subnet_ids" {
  value = aws_subnet.backend[*].id
}

output "db_subnet_ids" {
  value = aws_subnet.db[*].id
}

output "nat_gateway_id" {
  description = "ID de la NAT Gateway classique (AZ-a)"
  value       = aws_nat_gateway.this.id
}

output "internet_gateway_id" {
  value = aws_internet_gateway.this.id
}
