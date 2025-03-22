output "vpc_id" {
  value = aws_vpc.oneflow_vpc.id 
}

output "public_subnet_id" {
  value = aws_subnet.oneflow_public_subnet[0].id
}

output "private_subnet_id" {
  value = aws_subnet.oneflow_private_subnet[0].id
}
