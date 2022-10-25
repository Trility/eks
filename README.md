# EKS Cluster

## Dependencies
 - AWS VPC and private access

## Required Tools
 - Terraform

## Helpful Tools
 - AWS CLI
 - Helm CLI
 - Kubectl 

## Terraform plan/apply creates the following:
 - EKS Cluster, OpenID Connector and Node Group
 - AWS LB Controller - https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.2/
 - FluentBit - https://github.com/aws/eks-charts/tree/master/stable/aws-for-fluent-bit
 - External-DNS - https://github.com/kubernetes-sigs/external-dns
 - Supporting IAM roles and policies

## Variables
 - aws_lb_controller_version - helm search repo eks
 - aws_region - tested in us-west-2
 - cluster_name - User's choice
 - eks_node_group_ami - https://docs.aws.amazon.com/eks/latest/userguide/eks-optimized-ami.html
 - eks_version - https://docs.aws.amazon.com/eks/latest/userguide/kubernetes-versions.html
 - external_dns_version - helm search repo external-dns
 - hosted_zone_id - Private DNS Hosted Zone in Route53
 - subnet_ids - Private subnets
 - vpc_id - Fully functional vpc
