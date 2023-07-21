
## need to create EKS IAM Role First

resource "aws_iam_role" "eks_role" {
  name = "Eks-cluster_role"
  assume_role_policy =  jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role = aws_iam_role.eks_role.name
}

resource "aws_eks_cluster" "eks_cluster" {
  name = "eks_cluster"
  role_arn = aws_iam_role.eks_role.arn
  vpc_config {
    subnet_ids = [
        var.private-subnet-1-id,
        var.private-subnet-2-id,
        var.public-subnet-1-id,
        var.public-subnet-2-id
    ]
  }

  depends_on = [ aws_iam_role_policy_attachment.AmazonEKSClusterPolicy ]
}
