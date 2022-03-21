

# terraform-backend-state-123
#access key ID : AKIAUPKWME4XYPDF3LQW

terraform {
    backend "s3" {
        bucket = "mybucket" #will be overridden from build
        key = "path/to/my/key" #will be overridden from build
        region = "us-east-1"
    }
}

resource "aws_default_vpc" "default" {

}

data "aws_subnet_ids" "subnets" {
    vpc_id = aws_default_vpc.default.id 
}

provider "kubernetes" {
    host = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
    token = data.aws_eks_cluster.cluster.token
    load_config_file = false
    version = "~> 1.9"
}
module "in28minutes-cluster" {
    source = "terraform-aws-modules/eks/aws"
    cluster_name="in28minutes-cluster"
    cluster_version="1.14"
    subnet_ids = ["subnet-01550d52832700ac5","subnet-08a42ade7d72308ef"]
    #subnets = data.aws_subnet_ids.subnets.ids
    vpc_id = aws_default_vpc.default.id
    #vpc_id = "vpc-1234556abcdef"
    node_groups = [
        {
            instance_type = "t2.micro"
            max_capacity = 5
            desired_capacity =2
            min_capacity = 2
        }
    ]
}
data "aws_eks_cluster" "cluster"{
    name = module.my-cluster.cluster_id
}
data "aws_eks_cluster_auth" "cluster"{
    name = module.my-cluster.cluster_id
}

#we will use serviceaccount to connect to k8s cluster in CI/CD mode
# serviceaccount needs permissions to create deployments
#and services in default namespace

resource "kubernetes_cluster_role_binding" "exemple"{
    metadata {
      name = "fabric8-rbac"
    }
    role_ref {
      api_group = "rbac.authorization.k8s.io"
      kind = "ClusterRole"
      name = "cluster-admin"
    }
    subject {
        kind = "ServiceAccount"
        name = "default"
        namespace = "default"
    }
}
