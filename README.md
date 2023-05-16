# EKS Cluster

## Dependencies
 - AWS VPC and private access

## Required Tools
 - Terraform

## Helpful Tools
 - AWS CLI

## Terraform plan/apply creates the following:
 - EKS Cluster, OpenID Connector and Node Group
 - Supporting IAM roles and policies

## Variables
 - aws_region - tested in us-west-2
 - cluster_name - User's choice
 - eks_node_group_ami - https://github.com/awslabs/amazon-eks-ami/blob/master/CHANGELOG.md
 - eks_version - https://docs.aws.amazon.com/eks/latest/userguide/kubernetes-versions.html
 - kms_user - User for managing KMS keys
 - subnet_ids - Private subnets
 - vpc_id - Fully functional vpc
