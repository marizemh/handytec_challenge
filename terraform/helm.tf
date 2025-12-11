data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_name
  depends_on = [module.eks]
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_name
  depends_on = [module.eks]
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}

resource "helm_release" "hello" {
  name       = "hello-demo"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "nginx"
  version    = "15.0.0"

  set {
    name  = "image.repository"
    value = "nginxdemos/hello"
  }

  set {
    name  = "image.tag"
    value = "latest"
  }
  
  set {
    name  = "service.type"
    value = "LoadBalancer"
  }
}
