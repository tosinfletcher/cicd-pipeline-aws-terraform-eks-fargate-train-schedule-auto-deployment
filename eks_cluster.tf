terraform {
  required_providers {
    tls = {
      source = "hashicorp/tls"
      version = "3.4.0"
    }
  }
}


resource "aws_iam_role" "eks_role" {
  name = "eks_role"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [{
      "Effect" : "Allow",
      "Principal" : {
        "Service" : "eks.amazonaws.com"
      },
      "Action" : "sts:AssumeRole"
    }]
  })
}


resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_role.name
}


resource "aws_eks_cluster" "eks_cluster" {
  name     = "eks_cluster"
  role_arn = aws_iam_role.eks_role.arn


  vpc_config {
    endpoint_public_access  = true
    endpoint_private_access = false

    subnet_ids = [
      aws_subnet.public_1.id,
      aws_subnet.public_2.id,
      aws_subnet.public_3.id,
      aws_subnet.private_1.id,
      aws_subnet.private_2.id,
      aws_subnet.private_3.id
    ]
  }
  depends_on = [aws_iam_role_policy_attachment.AmazonEKSClusterPolicy]
}



resource "aws_iam_role" "eks_fargate_pod_execution_role" {
  name = "eks_fargate_pod_role"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [{
      "Effect" : "Allow",
      "Principal" : {
        "Service" : "eks-fargate-pods.amazonaws.com"
      },
      "Action" : "sts:AssumeRole"
    }]
  })
}


resource "aws_iam_role_policy_attachment" "AmazonEKSFargatePodPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
  role       = aws_iam_role.eks_fargate_pod_execution_role.name
}



data "tls_certificate" "eks_cluster_identity_oidc_issuer" {
  url = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks_openid_connect_provider" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks_cluster_identity_oidc_issuer.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
}



resource "aws_iam_role" "load_balancer_role_trust_policy" {
  name = "load_balancer_role_trust_policy"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [{
      "Effect" : "Allow",
      "Principal" : {
        "Federated" : "${aws_iam_openid_connect_provider.eks_openid_connect_provider.arn}"
      },
      "Action" : "sts:AssumeRoleWithWebIdentity",
      "Condition" : {
        "StringEquals" : {
          "${replace(aws_iam_openid_connect_provider.eks_openid_connect_provider.url, "https://", "")}:aud" : "sts.amazonaws.com",
          "${replace(aws_iam_openid_connect_provider.eks_openid_connect_provider.url, "https://", "")}:sub" : "system:serviceaccount:kube-system:aws-load-balancer-controller"
        }
      }
    }]
  })
}



resource "aws_iam_policy" "AWSLoadBalancerControllerIAMPolicy" {
  name   = "AWSLoadBalancerControllerIAMPolicy"
  path   = "/"
  policy = file("load_balancer_controller_iam_policy.json")
}



resource "aws_iam_role_policy_attachment" "load_balancer" {
  policy_arn = "arn:aws:iam::${aws_subnet.public_1.owner_id}:policy/AWSLoadBalancerControllerIAMPolicy"
  role       = aws_iam_role.load_balancer_role_trust_policy.name
}



resource "aws_eks_fargate_profile" "fargate" {
  cluster_name           = aws_eks_cluster.eks_cluster.name
  fargate_profile_name   = "fargate"
  pod_execution_role_arn = aws_iam_role.eks_fargate_pod_execution_role.arn
  subnet_ids             = [aws_subnet.private_1.id, aws_subnet.private_2.id, aws_subnet.private_3.id]

  selector {
    namespace = "default"
  }
}

resource "aws_eks_fargate_profile" "CoreDNS" {
  cluster_name           = aws_eks_cluster.eks_cluster.name
  fargate_profile_name   = "CoreDNS"
  pod_execution_role_arn = aws_iam_role.eks_fargate_pod_execution_role.arn
  subnet_ids             = [aws_subnet.private_1.id, aws_subnet.private_2.id, aws_subnet.private_3.id]

  selector {
    namespace = "kube-system"
  }

  tags = {
    k8s-app : "kube-dns"
  }
}
