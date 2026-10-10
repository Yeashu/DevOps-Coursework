# Terraform S3 verification

**Student:** Prabhav Semwal · **Enrollment:** 24BCS10358


`provider.tf` selects the AWS provider and region; `variables.tf` defines inputs; `terraform.tfvars` supplies example values; `main.tf` declares the resources; `outputs.tf` declares values exposed after execution. Terraform derives creation order from resource references.

```bash
terraform init -backend=false -input=false
terraform fmt -check
terraform validate
terraform test
terraform graph
```

The test uses a mock provider and checks that public access is blocked and non-empty bucket contents are protected. [Recorded verification](../README.md#recorded-execution-evidence).
