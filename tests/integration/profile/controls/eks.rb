control 'eks' do
  title 'EKS Configuration'
  describe aws_eks_cluster('vault') do
    its('version') { should eq '1.21' }
    its('tags') { should include("Environment"=>"test") }
    its('role_arn') { should cmp 'arn:aws:iam::533618305027:role/vault-eks-cluster' }
  end
end