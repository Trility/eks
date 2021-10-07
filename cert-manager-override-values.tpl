# Cert-Manager Helm Chart Value Overrides
installCRDs: true
serviceAccount:
  annotations:
    eks.amazonaws.com/role-arn: arn:aws:iam::${aws-account-id}:role/cert-manager
securityContext:
  enabled: true
  fsGroup: 1001
