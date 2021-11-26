control 'eks' do
  title 'eks'
  desc 'Testing EKS configuration'
  describe aws_eks_cluster(cluster_name: 'vault') do
    it { should exist }
  end
end
