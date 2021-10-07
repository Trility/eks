resource "aws_iam_policy" "external_dns" {
  name = "eks_external_dns"
  policy = templatefile("${path.module}/external_dns_policy.json", {
    hosted_zone_id = var.hosted_zone_id
  })
}

resource "aws_iam_role" "external_dns" {
  name = "eks_external_dns"

  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Federated": aws_iam_openid_connect_provider.cluster.arn
        },
        "Action": "sts:AssumeRoleWithWebIdentity",
        "Condition": {
          "StringEquals": {
            "${replace(aws_iam_openid_connect_provider.cluster.url, "https://", "")}:sub": "system:serviceaccount:kube-system:external-dns"
          }
        }
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "external_dns" {
  name = "eks_external_dns"
  policy_arn = aws_iam_policy.external_dns.arn
  roles = [ aws_iam_role.external_dns.name ]
}

resource "kubernetes_service_account" "external_dns" {
  metadata {
    name = "external-dns"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.external_dns.arn
    }
  }
  depends_on = [
    aws_eks_node_group.node_group,
  ]
}

resource "helm_release" "external_dns" {
  name = "external-dns"
  namespace = "kube-system"
  repository = "https://kubernetes-sigs.github.io/external-dns/"
  chart = "external-dns"
  version = var.external_dns_version
  
  set {
    name = "serviceAccount.create"
    value = "false"
  }

  set {
    name = "serviceAccount.name"
    value = "external-dns"
  }

  depends_on = [
    aws_eks_node_group.node_group,
  ]
}
