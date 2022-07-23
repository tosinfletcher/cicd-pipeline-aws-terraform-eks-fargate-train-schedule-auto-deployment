data "aws_eks_cluster_auth" "eks_cluster" {
  name = aws_eks_cluster.eks_cluster.id
}


resource "null_resource" "k8s_patcher" {
  depends_on = [aws_eks_fargate_profile.fargate, aws_eks_fargate_profile.CoreDNS]

  triggers = {
    endpoint = aws_eks_cluster.eks_cluster.endpoint
    ca_crt   = base64decode(aws_eks_cluster.eks_cluster.certificate_authority[0].data)
    token    = data.aws_eks_cluster_auth.eks_cluster.token
  }

  provisioner "local-exec" {
    command = <<EOH
cat >/tmp/ca.crt <<EOF
${base64decode(aws_eks_cluster.eks_cluster.certificate_authority[0].data)}
EOF
kubectl \
  --server="${aws_eks_cluster.eks_cluster.endpoint}" \
  --certificate_authority=/tmp/ca.crt \
  --token="${data.aws_eks_cluster_auth.eks_cluster.token}" \
  patch deployment coredns \
  -n kube-system --type json \
  -p='[{"op": "remove", "path": "/spec/template/metadata/annotations/eks.amazonaws.com~1compute-type"}]'
EOH
  }

  lifecycle {
    ignore_changes = [triggers]
  }
}

