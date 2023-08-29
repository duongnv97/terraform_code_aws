variable "master_prefix" {
  description = "Master prefix for all AWS Resources"
  type        = string
}

variable "env_prefix" {
  description = "Environment prefix for all AWS Resources"
  type        = string
}

variable "app_prefix" {
  description = "Application prefix for all AWS Resources"
  type        = string
}

variable "tags" {
  description = "A map of additional tags to add to all resource"
  type        = map(string)
  default     = {}
}


#------variable for rds---------------#
variable "db_allocate_storage" {
  description = "RDS allocate storage"
  type        = number
  default = 20
}
variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
}
variable "db_multi_az_enabled" {
  description = "RDS multi AZ"
  type        = string
}

#------variable for vpc---------------#
variable "vpc_cidr" {
  description = "Application prefix for all AWS Resources"
  type        = string
}

variable "private_subnets" {
  description = "A list of private subnets inside the VPC"
  type        = list(string)
}

variable "public_subnets" {
  description = "A list of public subnets inside the VPC"
  type        = list(string)
}

variable "data_subnets" {
  description = "A list of data subnets inside the VPC"
  type        = list(string)
}

variable "azs" {
  description = "AZs in AWS Region"
  type        = list(string)
}

variable "igw_enable" {
  description = "The boolen flog whether a Internet Gateway should be deployed"
  type        = bool
  default     = true

}

# variable "igw_enable" {
#   description = "The boolen flag whether a Internet Gateway should be deployed"
#   type        = bool
#   default     = true
# }

variable "nat_gateways_enable" {
  description = "The boolen flag whether a NAT Gateway should be deployed in each AZ"
  type        = bool
  default     = true
}

variable "vpc_flow_log_enable_s3" {
  description = "The boolen flag whether a vpc follow logs to s3 should be deployed "
  type        = bool
  default     = true
}
#------------Security group-------------
variable "aws_private_subnet_node" {
  description = "VPC private subnet id"
  type        = list(string)
}

#-------------- EC2 key pair-----------
variable "ec2_key_name" {
  description = "Ec2 key pair for ec2"
  type        = string
}

variable "bastion_instance_type" {
  description =  "Instance type for bastion server"
  type = string
}

variable "ebs_volume_size" {
  description =  "Volume size of ebs bastion"
  type = number
}

variable "ebs_volume_type" {
  description =  "Volume type of ebs bastion"
  type = string
}

variable "ebs_iops" {
  description =  "Volume iops of ebs bastion"
  type = number
}

variable "ebs_throughput" {
  description =  "Volume throughput of ebs bastion"
  type = number
}

#-------------------EKS cluster-----------
variable "cluster_log_retention_in_days" {
  description =  "Time to retention logs for eks cluster"
  type = number
}

variable "cluster_name" {
  description =  "EKS cluster name"
  type = string
}

variable "eks_cluster_version" {
  description =  "EKS cluster version"
  type = number
}

variable "cluster_endpoint_private_access" {
  description = "Indicates whether or not the Amazon EKS private API server endpoint is enabled"
  type        = bool
  default     = true
}

variable "cluster_endpoint_public_access" {
  description = "Indicates whether or not the Amazon EKS public API server endpoint is enabled"
  type        = bool
  default     = false
}

variable "cluster_endpoint_public_access_cidrs" {
  description = "List of CIDR blocks which can access the Amazon EKS public API server endpoint"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "cluster_service_ipv4_cidr" {
  description = "The CIDR block to assign Kubernetes service IP addresses from. If you don't specify a block, Kubernetes assigns addresses from either the 10.100.0.0/16 or 172.20.0.0/16 CIDR blocks"
  type        = string
  default     = null
}

variable "cluster_encryption_config" {
  description = "Configuration block with encryption configuration for the cluster. To disable secret encryption, set this value to `{}`"
  type        = any
  default = {
    resources = ["secrets"]
  }
}

variable "cluster_tags" {
  description = "A map of additional tags to add to the cluster"
  type        = map(string)
  default     = {}
}

variable "cluster_create_timeout" {
  description = "Timeout value when creating the EKS cluster."
  type        = string
  default     = "30m"
}

variable "cluster_delete_timeout" {
  description = "Timeout value when deleting the EKS cluster."
  type        = string
  default     = "15m"
}

#-------------------Node group---------
variable "node_volume_size" {
  description =  "Volume size of ebs bastion"
  type = number
}

variable "instance_type" {
  description =  "Instance type for node group"
  type = string
}


variable "desired_size" {
  description =  "desired_size of node group"
  type = number
}

variable "max_size" {
  description =  "max_size of node group"
  type = number
}

variable "min_size" {
  description =  "min_size of node group"
  type = number
}

variable "update_config" {
  type        = list(map(number))
  default     = []
  description = <<-EOT
    Configuration for the `eks_node_group` [`update_config` Configuration Block](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_node_group#update_config-configuration-block).
    Specify exactly one of `max_unavailable` (node count) or `max_unavailable_percentage` (percentage of nodes).
    EOT
}

variable "node_group_terraform_timeouts" {
  type = list(object({
    create = string
    update = string
    delete = string
  }))
  default     = []
  description = <<-EOT
    Configuration for the Terraform [`timeouts` Configuration Block](https://www.terraform.io/docs/language/resources/syntax.html#operation-timeouts) of the node group resource.
    Leave list empty for defaults. Pass list with single object with attributes matching the `timeouts` block to configure it.
    Leave attribute values `null` to preserve individual defaults while setting others.
    EOT
}

#-------------------Redis---------
variable "user_id" {
  description = ""
  type = string
}

variable "user_name" {
  description = ""
  type = string
}

variable "access_string" {
  description = ""
  type = string
}


variable "user_id_default" {
  description = ""
  type = string
}

variable "user_group_name" {
  description = ""
  type = string
}

variable "multi_az_enabled" {
  description = ""
  type = string
}

variable "cluster_mode_num_node_groups" {
  description = ""
  type = number
  default = 0
}

variable "cluster_mode_nucluster_mode_replicas_per_node_groupm_node_groups" {
  description = ""
  type = number
  default = 0
}