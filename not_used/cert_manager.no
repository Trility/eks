resource "aws_iam_policy" "cert_manager" {
  name = "eks_cert_manager"
  policy = "${file("cert_manager_policy.json")}"
}

resource "aws_iam_role" "cert_manager" {
  name = "eks_cert_manager"

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
            "${replace(aws_iam_openid_connect_provider.cluster.url, "https://", "")}:sub": "system:serviceaccount:cert-manager:cert-manager"
          }
        }
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "cert_manager" {
  name = "eks_cert_manager"
  policy_arn = aws_iam_policy.cert_manager.arn
  roles = [ aws_iam_role.cert_manager.name ]
}

resource "kubernetes_namespace" "cert-manager" {
  metadata {
    name = "cert-manager"
  }
  depends_on = [
    aws_eks_node_group.node_group,
  ]
}

resource "helm_release" "cert_manager" {
  name = "cert-manager"
  namespace = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart = "cert-manager"
  version = "v1.5.3"
  values = [
    templatefile("cert-manager-override-values.tpl", {
      aws-account-id = data.aws_caller_identity.current.account_id
    })
  ]
  depends_on = [
    aws_eks_node_group.node_group,
  ]
}

resource "kubectl_manifest" "cluster_issuer" {
  yaml_body = file("cluster_issuer.yaml")
  depends_on = [
    helm_release.cert_manager
  ]
}
