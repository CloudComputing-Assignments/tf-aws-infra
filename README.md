# tf-aws-infra

# Terraform and AWS Infrastructure Guide

## Assignment 3 - Terraform Script to Create VPC with Custom Subnet

This guide provides an overview and useful commands for using Terraform to manage infrastructure in Amazon Web Services(AWS).

### Terraform Useful Commands

To manage your Terraform infrastructure, use the following commands:

- Initialize Terraform directory:
  ```
  terraform init
  ```

- Validate the Terraform files:
  ```
  terraform validate
  ```

- Create an execution plan:
  ```
  terraform plan
  ```

- Apply the changes required to reach the desired state of the configuration:
  ```
  terraform apply
  ```

### Required `.tfvars` Variables

For the Terraform scripts to work, ensure you have a `.tfvars` file with the following variables:

```hcl
aws_region = "region-name"
aws_profile = "your-aws-profile"
vpc_cidr = "your-network"
availability_zones = ["zone1", "zone2", "zone3"]
public_subnet_cidrs = ["address1", "address2", "address3"]
private_subnet_cidrs = ["address1", "address2", "address3"]
tags = {
  Name = "your-vpc--name"
}
```
Make sure to replace the values to fit your needs.

### Using Workspace for Isolated States

Workspaces allow you to manage different states for your infrastructure, useful for managing different environments (e.g., development, staging, production).

1. **Create a New Workspace:**
   ```shell
   terraform workspace new <workspace_name>
   ```

2. **Apply Configuration for a Workspace:**
   ```shell
   terraform apply -var-file="<filename>"
   ```

3. **Workspace Management Commands:**
    - **List Workspaces:**
      ```shell
      terraform workspace list
      ```
    - **Switch Workspace:**
      ```shell
      terraform workspace select <workspace_name>
      ```
    - **Delete Workspace:**
      **Note:** This will delete the state files. Make sure to destroy resources before deleting the workspace.
      ```shell
      terraform workspace delete -force <workspace_name>
      ```

