mock_provider "aws" {}
run "s3_configuration" {
  command = plan
  assert {
    condition     = aws_s3_bucket.demo.force_destroy == false
    error_message = "The bucket must protect non-empty contents."
  }
  assert {
    condition     = aws_s3_bucket_public_access_block.demo.block_public_acls && aws_s3_bucket_public_access_block.demo.block_public_policy
    error_message = "Public bucket access must be blocked."
  }
}
