#
# Variables Configuration
#


## Define cluster-name as per your choice in "default" ##
variable "cluster-name" {
  default     = "cluster-AumKale-178"
  type    = "string"
}


## make sure you have followed https://github.com/mayadata-io/mayalabs-infra/blob/master/Terraform/AWS/EKS-CLUSTER-CREATE/Examples/AWS-ssh-keypair-create.md ##
variable "ssh_key_pair" {
   default     = "terraform"  

}

variable "eks_version" {
  default     = 1.18

}

variable "region" {
  default     = "us-east-1"

}

## make sure you followed https://www.ec2instances.info/?selected=r5ad.xlarge,r3.xlarge (Before selecting,select your region adn ask if you really need that type) ##
variable "instance_type" {
   default  = "m4.xlarge"
   
}

## make sure you followed https://console.aws.amazon.com/ec2sp/v1/spot/home?region=us-east-1 (select the last 3 months behaviour.Always give price closer to ON-DEMAND) ##
variable "spot_price" {
   default  = "0.1500"
}
