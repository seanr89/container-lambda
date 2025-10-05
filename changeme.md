## Terraform and S3 Bucket Changes

This is a summary of the recent changes made to the Terraform configuration and related AWS resources.

### Terraform Configuration (`infra/main.tf`)

- **S3 Bucket Notification:** The `aws_s3_bucket_notification` resource was corrected to use the `lambda_function` block instead of the incorrect `queue` block.
- **Unique S3 Bucket Names:** Implemented the `random_id` resource to generate a unique suffix for the S3 bucket name, preventing conflicts with existing bucket names.
- **S3 Bucket ACLs:** Removed the `aws_s3_bucket_acl` resource and added `aws_s3_bucket_ownership_controls` and `aws_s3_bucket_public_access_block` to manage bucket ownership and public access, aligning with modern S3 best practices.
- **Dependencies:** Added a `depends_on` clause to the `aws_s3_bucket_notification` resource to ensure the `aws_lambda_permission` is created first, preventing race conditions.

### Makefile (`Makefile`)

- **Terraform Apply:** The `apply` command in the `Makefile` was updated to include the `-auto-approve` flag, allowing for non-interactive deployments.

### ECR Image (`scripts/push_image.sh`)

- **Image Push:** The `push_image.sh` script was executed to ensure the Docker image was available in the Amazon ECR repository for the Lambda function to use.
