provider "aws" {
  version = "~>2.9"
  region = "${var.region}"
}

data "aws_eks_cluster" "cluster" {
  name = "${module.eks.cluster_id}"
}

data "aws_eks_cluster_auth" "cluster" {
  name = "${module.eks.cluster_id}"
}

provider "kubernetes" { 
  version = "~>1.6"
  host = "${data.aws_eks_cluster.cluster.endpoint}"
  cluster_ca_certificate = "${base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)}"
  token = "${data.aws_eks_cluster_auth.cluster.token}"
  load_config_file = "false"
}
