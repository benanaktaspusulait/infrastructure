#!/bin/bash
echo "⚠️ Cleaning Terraform..."

terraform destroy -auto-approve
rm -rf .terraform/ terraform.tfstate terraform.tfstate.backup
rm -rf .terraform.lock.hcl crash.log
rm -rf .terraform/ terraform.tfstate terraform.tfstate.backup .terraform.lock.hcl crash.log

echo "✅ Cleaning complete. "