control 'eks' do
  title 'eks'
  desc 'EKS configuration'
  describe aws_eks_cluster('vault') do
    its('version') { should eq '1.21' }
    its('tags') { should include("Environment"=>"test") }
    # its('tags') { should include(key: 'Environment', value: 'Test') }
    its('role_arn') { should cmp 'arn:aws:iam::533618305027:role/vault-eks-cluster' }
  end
end
