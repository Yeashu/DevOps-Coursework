mock_provider "aws" {}
run "infrastructure_configuration" {
  command = plan
  assert {
    condition     = aws_subnet.app.cidr_block == var.subnet_cidr && aws_vpc.main.cidr_block == var.vpc_cidr
    error_message = "The network ranges must match the declared inputs."
  }
  assert {
    condition     = aws_instance.app.associate_public_ip_address == false
    error_message = "The instance must not receive a public IP."
  }
  assert {
    condition     = aws_instance.app.metadata_options[0].http_tokens == "required"
    error_message = "IMDSv2 must be required."
  }
}
