

output "instance_1_public_ip" {
  value = aws_instance.instance_1.public_ip
}


output "instance_2_public_ip" {
  value = aws_instance.instance_2.public_ip
}

output "rds_endpoint" {
  value = aws_db_instance.my_database.endpoint
}

