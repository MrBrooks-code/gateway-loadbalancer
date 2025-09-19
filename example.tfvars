  module "gwlb" {
    source = "./path/to/module"

    name       = "security-gwlb"
    subnet_ids = ["subnet-123", "subnet-456"]
    vpc_id     = "vpc-abc123"

    # Enable logging with S3 integration
    access_logs_enabled     = true
    access_logs_bucket_name = "my-gwlb-access-logs"
    access_logs_prefix      = "production/access-logs"
    
    connection_logs_enabled     = true
    connection_logs_bucket_name = "my-gwlb-connection-logs"
    connection_logs_prefix      = "production/connection-logs"

    # S3 security settings
    s3_versioning_enabled = true
    s3_sse_algorithm     = "aws:kms"
    s3_kms_master_key_arn = "arn:aws:kms:us-east-1:123456789012:key/12    
  345678-1234-1234-1234-123456789012"
  }