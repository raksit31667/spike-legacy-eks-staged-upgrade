data "aws_caller_identity" "current" {}

# Create an IAM role for the EKS Cluster Autoscaler
resource "aws_iam_role" "eks_cluster_autoscaler" {
  name = "eks-cluster-autoscaler-role"

  # Trust relationship for the EKS OIDC provider
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(data.aws_eks_cluster.demo_eks.identity[0].oidc[0].issuer, "https://", "")}"
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "${replace(data.aws_eks_cluster.demo_eks.identity[0].oidc[0].issuer, "https://", "")}:sub" : "system:serviceaccount:kube-system:cluster-autoscaler"
          }
        }
      }
    ]
  })
}

# Attach the necessary policies to the IAM role for autoscaling
resource "aws_iam_policy" "eks_cluster_autoscaler_policy" {
  name        = "eks-cluster-autoscaler-policy"
  description = "Policy for EKS Cluster Autoscaler"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:DescribeAutoScalingInstances",
          "autoscaling:DescribeLaunchConfigurations",
          "autoscaling:DescribeScalingActivities",
          "autoscaling:SetDesiredCapacity",
          "autoscaling:TerminateInstanceInAutoScalingGroup",
          "ec2:DescribeImages",
          "ec2:DescribeInstanceTypes",
          "ec2:DescribeLaunchTemplateVersions",
          "ec2:GetInstanceTypesFromInstanceRequirements",
          "eks:DescribeNodegroup",
        ],
        Resource = "*"
      }
    ]
  })
}

# Attach the policy to the IAM role
resource "aws_iam_role_policy_attachment" "eks_cluster_autoscaler_policy_attach" {
  role       = aws_iam_role.eks_cluster_autoscaler.name
  policy_arn = aws_iam_policy.eks_cluster_autoscaler_policy.arn
}
