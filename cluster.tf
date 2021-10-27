resource "aws_iam_role" "cluster-eks" {
  name = "${var.cluster_name}-eks-cluster"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "cluster-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role = aws_iam_role.cluster-eks.name
}

resource "aws_iam_role_policy_attachment" "cluster-AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role = aws_iam_role.cluster-eks.name
}

resource "aws_eks_cluster" "cluster" {
  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  name = var.cluster_name
  role_arn = aws_iam_role.cluster-eks.arn
  version  = var.eks_version
  vpc_config {
    subnet_ids = [aws_subnet.private_az1.id, aws_subnet.private_az2.id, aws_subnet.private_az3.id, aws_subnet.private_az4.id]
    #    subnet_ids = concat(tolist(data.aws_subnet_ids.private.ids), tolist(data.aws_subnet_ids.public.ids)) 
  }
}

data "tls_certificate" "cert" {
  url = aws_eks_cluster.cluster.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "cluster" {
  client_id_list = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.cert.certificates[0].sha1_fingerprint]
  url = aws_eks_cluster.cluster.identity[0].oidc[0].issuer
}

output "openid_url" {
  value = aws_iam_openid_connect_provider.cluster.url
}

output "openid_arn" {
  value = aws_iam_openid_connect_provider.cluster.arn
}

resource "aws_launch_template" "eks_launch_template" {
  name = var.cluster_name
  /*
  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      delete_on_termination = true
      encrypted = true
      # throughput = 500
      volume_size = 100
      volume_type = "gp2"
    }
  }
  ebs_optimized = true
  */
  instance_type = "t3.medium"
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "eks-${var.cluster_name}"
    }
  }
  tag_specifications {
    resource_type = "volume"
    tags = {
      Name = "eks-${var.cluster_name}"
    }
  }
}

resource "aws_iam_role" "node-group" {
  name = "${var.cluster_name}-eks-node-group"
  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role = aws_iam_role.node-group.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role = aws_iam_role.node-group.name
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role = aws_iam_role.node-group.name
}

resource "aws_eks_node_group" "node_group" {
  cluster_name = aws_eks_cluster.cluster.name
  launch_template {
    name = aws_launch_template.eks_launch_template.name
    version = aws_launch_template.eks_launch_template.latest_version
  }
  node_group_name = var.cluster_name
  node_role_arn = aws_iam_role.node-group.arn
  release_version = var.eks_node_group_ami
  subnet_ids = [aws_subnet.private_az1.id, aws_subnet.private_az2.id, aws_subnet.private_az3.id, aws_subnet.private_az4.id]
  scaling_config {
    desired_size = 5
    max_size = 5
    min_size = 5
  }
  version = var.eks_version

  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
    aws_launch_template.eks_launch_template,
  ]
}
