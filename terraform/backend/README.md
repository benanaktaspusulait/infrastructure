# Terraform Backend Configuration

This directory contains the configuration for the Terraform backend, which is used to store the Terraform state file in a remote location (AWS S3) with state locking (AWS DynamoDB).

## Features

- Remote state storage in S3
- State locking with DynamoDB
- Versioning enabled for state files
- Server-side encryption
- Public access blocking
- Lifecycle protection against accidental deletion

## Prerequisites

- AWS CLI configured with appropriate credentials
- Terraform >= 1.0.0

## Usage

1. Initialize the backend:
   ```bash
   terraform init
   ```

2. Create a `terraform.tfvars` file with your configuration:
   ```hcl
   environment         = "dev"
   state_bucket_name  = "your-terraform-state-bucket"
   aws_region        = "us-west-2"
   ```

3. Apply the configuration:
   ```bash
   terraform plan
   terraform apply
   ```

## Configuration

### S3 Backend

The S3 backend is configured with the following features:
- Versioning enabled for state files
- Server-side encryption using AES256
- All public access blocked
- Lifecycle protection against accidental deletion

### DynamoDB State Locking

The DynamoDB table is configured with:
- On-demand billing mode
- LockID as the partition key
- String type for the LockID attribute

## Security Considerations

1. The S3 bucket is configured with:
   - Server-side encryption
   - No public access
   - Versioning enabled
   - Lifecycle protection

2. The DynamoDB table uses:
   - On-demand billing to minimize costs
   - Minimal required attributes for state locking

## Outputs

- `s3_bucket_name`: The name of the created S3 bucket
- `dynamodb_table_name`: The name of the created DynamoDB table

## Maintenance

### Updating the Backend

1. Make changes to the configuration
2. Run `terraform plan` to review changes
3. Apply changes with `terraform apply`

### Backup and Recovery

The state file is automatically versioned in S3. To restore a previous version:
1. Navigate to the S3 bucket
2. Find the desired version in the version history
3. Download and restore the state file

## Troubleshooting

### Common Issues

1. State Lock Issues:
   ```bash
   # Force unlock if needed (use with caution)
   terraform force-unlock <LOCK_ID>
   ```

2. Backend Configuration Issues:
   ```bash
   # Reinitialize backend
   terraform init -reconfigure
   ```

3. S3 Access Issues:
   - Verify AWS credentials
   - Check IAM permissions
   - Ensure bucket name is unique 