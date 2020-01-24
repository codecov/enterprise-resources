# Example EKS cluster
# This creates an EKS cluster for the Codecov Enterprise application.
# There are 3 node groups created: web, worker, and minio.  The k8s
# deployments are set up to execute on their respective node groups
# using the `role` label.

locals {
  worker_groups_launch_template = [
    {
      name = "web"
      instance_type = "${var.web_node_type}"
      subnets = "${join(",", module.vpc.private_subnets)}"
      asg_desired_capacity = "${var.web_nodes}"
      kubelet_extra_args = "--node-labels=kubernetes.io/role=web"
      eni_delete = "true"
    },
    {
      name = "worker"
      instance_type = "${var.worker_node_type}"
      subnets = "${join(",", module.vpc.private_subnets)}"
      asg_desired_capacity = "${var.worker_nodes}"
      kubelet_extra_args = "--node-labels=kubernetes.io/role=worker"
      eni_delete = "true"
    },
    {
      name = "minio"
      instance_type = "${var.minio_node_type}"
      subnets = "${join(",", module.vpc.private_subnets)}"
      asg_desired_capacity = "${var.minio_nodes}"
      kubelet_extra_args = "--node-labels=kubernetes.io/role=minio"
      eni_delete = "true"
    },
  ]
}

module "eks" {
  source = "terraform-aws-modules/eks/aws"
  version = "4.0.1"
  cluster_name = "${var.cluster_name}"
  subnets = ["${module.vpc.private_subnets}"]
  vpc_id = "${module.vpc.vpc_id}"
  worker_group_count = "0"
  worker_groups_launch_template = "${local.worker_groups_launch_template}"
  worker_group_launch_template_count = "3"
  cluster_enabled_log_types = ["api","controllerManager","scheduler"]
  workers_additional_policies = ["${aws_iam_policy.worker-s3.id}"]
  workers_additional_policies_count = "1"
}
