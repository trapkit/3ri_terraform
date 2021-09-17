data "aws_eks_cluster" "cluster" {
  name = module.my-cluster.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.my-cluster.cluster_id
}


provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
  version                = "~> 1.9"
}
########Security-Group###############################

resource "aws_security_group" "demo-cluster" {
  #name        = "var.aws_security_group.demo-cluster"
  description = "Cluster communication with worker nodes"
  vpc_id      = aws_vpc.demo.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.cluster-name}-sg"
  }
}

resource "aws_security_group_rule" "demo-cluster-ingress-workstation-ssh" {
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow ssh"
  from_port         = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.demo-cluster.id
  to_port           = 22
  type              = "ingress"
}

resource "aws_security_group_rule" "demo-cluster-ingress-workstation-tcp" {
  cidr_blocks       = ["10.0.0.0/16"]
  description       = "Allow port"
  from_port         = 0
  protocol          = "tcp"
  security_group_id = aws_security_group.demo-cluster.id
  to_port           = 65535
  type              = "ingress"
}

resource "aws_security_group_rule" "demo-cluster-ingress-workstation-udp" {
  cidr_blocks       = ["10.0.0.0/16"]
  description       = "Allow port"
  from_port         = 0
  protocol          = "udp"
  security_group_id = aws_security_group.demo-cluster.id
  to_port           = 65535
  type              = "ingress"
}

######################################################################

module "my-cluster" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = var.cluster-name
  cluster_version = var.eks_version
  subnets         = aws_subnet.demo[*].id
  vpc_id          = aws_vpc.demo.id
    

#######################################################################  
## Added on 11th Oct 2020 for testing purpose
#######################################################################

# node_groups = {
#     example = {
#       desired_capacity = 1
#       max_capacity     = 10
#       min_capacity     = 1

#       instance_type = "m4.xlarge"
#           }
#   }
 ##################################################################### 

  worker_groups = [
    {
      name                = "${var.cluster-name}-on-demand-1"
      instance_type       = "${var.instance_type}"
      asg_max_size       = 1
      kubelet_extra_args  = "--node-labels=node.kubernetes.io/lifecycle=normal"
      additional_security_group_ids = [aws_security_group.demo-cluster.id]
      suspended_processes = ["AZRebalance"]
      key_name            = var.ssh_key_pair
      #user_data           = "${file("iscsi.sh")}"
      #user_data           = "${data.template_file.iscsi.template}"
      public_ip           = "true"
      #ami_id              = "ami-0dba2cb6798deb6d8"
      
      
    },
    {
      name                = "${var.cluster-name}-spot-1"
      spot_price          = "${var.spot_price}"
      instance_type       = "${var.instance_type}"
      asg_max_size        = 3
      kubelet_extra_args  = "--node-labels=node.kubernetes.io/lifecycle=spot"
      additional_security_group_ids = [aws_security_group.demo-cluster.id]
      suspended_processes = ["AZRebalance"]
      key_name            = var.ssh_key_pair
      #user_data           = "${file("iscsi.sh")}"
      #user_data           = "${data.template_file.iscsi.template}"
      public_ip           = "true"
      #ami_id              = "ami-0dba2cb6798deb6d8"
      
   

    },
    {
      name                = "${var.cluster-name}-spot-2"
      spot_price          = "${var.spot_price}"
      instance_type       = "${var.instance_type}"
      asg_max_size        = 3
      kubelet_extra_args  = "--node-labels=node.kubernetes.io/lifecycle=spot"
      additional_security_group_ids = [aws_security_group.demo-cluster.id]
      suspended_processes = ["AZRebalance"]
      key_name            = var.ssh_key_pair
      #user_data           = "${file("iscsi.sh")}"
      #user_data           = "${data.template_file.iscsi.template}"
      public_ip           = "true"
      #ami_id              = "ami-0dba2cb6798deb6d8"
      
    }
  ]
}
