resource "aws_iam_policy" "lb_controller" {
  name   = "eks_load_balancer_controller"
  policy = file("eks_lb_policy_controller.json")
}

resource "aws_iam_role" "lb_controller" {
  name = "eks_lb_controller"

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
            "${replace(aws_iam_openid_connect_provider.cluster.url, "https://", "")}:sub" : "system:serviceaccount:kube-system:aws-load-balancer-controller"
          }
        }
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "lb_controller" {
  name       = "eks_lb_controller"
  policy_arn = aws_iam_policy.lb_controller.arn
  roles      = [aws_iam_role.lb_controller.name]
}
/*
resource "kubernetes_service_account" "lb_controller" {
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"
    labels = {
      "app.kubernetes.io/component" = "controller"
      "app.kubernetes.io/name"      = "aws-load-balancer-controller"
    }
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.lb_controller.arn
    }
  }
  depends_on = [
    aws_eks_node_group.node_group,
  ]
}
*/
resource "kubectl_manifest" "lb_crds" {
  yaml_body = file("eks_lb_controller_crds.yaml")
  depends_on = [
    aws_eks_node_group.node_group,
  ]
}

resource "helm_release" "lb_controller" {
  name       = "aws-load-balancer-controller"
  namespace  = "kube-system"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = var.aws_lb_controller_version

  set {
    name  = "clusterName"
    value = aws_eks_cluster.cluster.name
  }

  #set {
  #  name  = "serviceAccount.create"
  #  value = "false"
  #}

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.lb_controller.arn
  }
  depends_on = [
    aws_eks_node_group.node_group,
  ]
}
/*
resource "kubectl_manifest" "ingress_class" {
  yaml_body = <<YAML
apiVersion: networking.k8s.io/v1
kind: IngressClass
metadata:
  name: alb
spec:
  controller: ingress.k8s.aws/alb
YAML
  depends_on = [
    aws_eks_node_group.node_group,
  ]
}
*/
