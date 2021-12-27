control 'eks' do
  title 'eks'
  desc 'Testing EKS configuration'
  describe aws_eks_cluster(cluster_name: 'vault') do
    its('version') { should eq '1.21' }
    its('tags') { should include(key: 'Environment', value: 'Test') }
    its('tags_hash') { should include('tf_managed' => 'True') }
  end
end
