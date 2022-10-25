resource "aws_iam_policy" "fluent_bit" {
  name   = "eks_fluent_bit"
  policy = file("fluent_bit_policy.json")
}

resource "aws_iam_role" "fluent_bit" {
  name = "eks_fluent_bit"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Federated" : aws_iam_openid_connect_provider.cluster.arn
        },
        "Action" : "sts:AssumeRoleWithWebIdentity",
        "Condition" : {
          "StringEquals" : {
            "${replace(aws_iam_openid_connect_provider.cluster.url, "https://", "")}:sub" : "system:serviceaccount:kube-system:aws-for-fluent-bit"
          }
        }
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "fluent_bit" {
  name       = "eks_fluent_bit"
  policy_arn = aws_iam_policy.fluent_bit.arn
  roles      = [aws_iam_role.fluent_bit.name]
}

resource "kubernetes_service_account" "fluent_bit" {
  metadata {
    name      = "aws-for-fluent-bit"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.fluent_bit.arn
    }
  }
  depends_on = [
    aws_eks_node_group.node_group,
  ]
}

resource "helm_release" "fluent_bit" {
  name       = "aws-for-fluent-bit"
  namespace  = "kube-system"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-for-fluent-bit"
  version    = "0.1.17"

  set {
    name  = "serviceAccount.create"
    value = "false"
  }

  set {
    name  = "cloudWatch.region"
    value = var.aws_region
  }

  set {
    name  = "cloudWatch.logGroupName"
    value = "/aws/eks/${var.cluster_name}/fluentbit-cloudwatch/logs"
  }

  set {
    name  = "cloudWatch.logKey"
    value = "log"
  }

  set {
    name  = "firehose.enabled"
    value = "false"
  }

  set {
    name  = "kinesis.enabled"
    value = "false"
  }

  set {
    name  = "elasticsearch.enabled"
    value = "false"
  }

  depends_on = [
    kubernetes_service_account.fluent_bit,
  ]
}
