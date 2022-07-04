resource "helm_release" "tfletcher-load-balancer-controller" {
  name = "tfletcher-load-balancer-controller"

  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  version    = "1.4.2"

  set {
    name  = "clusterName"
    value = aws_eks_cluster.tfletcher_eks_cluster.name
  }

  set {
    name  = "image.tag"
    value = "v2.4.2"
  }

  set {
    name  = "replicaCount"
    value = 1
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.tfletcher_load_balancer_role_trust_policy.arn
  }

  # EKS Fargate specific
  set {
    name  = "region"
    value = var.region
  }

  set {
    name  = "vpcId"
    value = aws_vpc.tfletcher_vpc.id
  }

  depends_on = [aws_eks_fargate_profile.tfletcher_fargate, aws_eks_fargate_profile.CoreDNS]
}
