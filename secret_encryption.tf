resource "aws_kms_key" "eks_secret_encryption" {
  description             = "eks ${var.cluster_name} secret encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  policy = <<EOT
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "kms:*",
      "Principal": {
        "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
      },
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Action": [
        "kms:CreateGrant",
        "kms:CreateKey",
        "kms:Describe*",
        "kms:List*"
      ],
      "Effect": "Allow",
      "Resource": "*",
      "Principal": {
        "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/${var.kms_user}"
       }
    }
  ]
}
EOT
}

resource "aws_kms_alias" "eks_secret_encrption" {
  name          = "alias/eks-${var.cluster_name}-secret-encryption"
  target_key_id = aws_kms_key.eks_secret_encryption.key_id
}
