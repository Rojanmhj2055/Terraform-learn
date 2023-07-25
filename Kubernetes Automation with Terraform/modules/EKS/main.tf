
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


## Create a single instance group for Kubernetes. Similar to the EKS cluster
## it need an IAM Role

resource "aws_iam_role" "nodes" {
  name = "eks-node-group-nodes"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "nodes-AmazonEKSNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role = aws_iam_role.nodes.name
}


resource "aws_iam_role_policy_attachment" "nodes-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role = aws_iam_role.nodes.name
}

resource "aws_iam_role_policy_attachment" "nodes-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"'
  role = aws_iam_role.nodes.name
}

resource "aws_eks_node_group" "private-nodes"{
  cluster_name = aws_eks_cluster.eks_cluster.name
  node_group_name =  "private_node"
  node_node_role_arn = aws_iam_role.nodes.arn
  subnet_ids =[var.private-subnet-1-id,
                var.private-subnet-2-id
              ]
  capacity_type ="ON_DEMAND"
  instance_type =["t3.small"]

  //by default EKS nodes does not scale
  scaling_config{
    desired_size = 1
    max_size = 5
    min_size=0
  }

  update_config {
    max_unavailable=1
  }
  labels={
    role="general"
  }

 depends_on = [
    aws_iam_role_policy_attachment.example-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.example-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.example-AmazonEC2ContainerRegistryReadOnly,
  ]
  }