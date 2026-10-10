output "vpc_id" {
  value = aws_vpc.main.id
}
output "subnet_id" {
  value = aws_subnet.app.id
}
output "instance_id" {
  value = aws_instance.app.id
}
output "bucket_name" {
  value = aws_s3_bucket.artifacts.id
}
