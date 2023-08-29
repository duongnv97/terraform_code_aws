module "main" {
  source = "../../modules"
  master_prefix = "vn"
  env_prefix = "dev"
  app_prefix = "retail"

#------------ VPC----------
  vpc_cidr = "10.35.0.0/16"
  private_subnets =  ["10.35.0.0/24", "10.35.3.0/24", "10.35.6.0/24"]
  public_subnets = ["10.35.1.0/24", "10.35.4.0/24", "10.35.7.0/24"]
  data_subnets = ["10.35.2.0/24", "10.35.5.0/24", "10.35.8.0/24"]
  azs = ["us-east-1a", "us-east-1b", "us-east-1b"]
  igw_enable = true
  nat_gateways_enable = true
  vpc_flow_log_enable_s3 =  true

#------------ SG----------
  aws_private_subnet_node = ["10.35.0.0/24", "10.35.3.0/24", "10.35.6.0/24"]
  ec2_key_name = ""
  bastion_instance_type = "t3.medium"
  ebs_volume_size = 30
  ebs_volume_type = "gp3"
  ebs_iops = 3000
  ebs_throughput = 125

#-------------------EKS cluster-----------
  cluster_log_retention_in_days = 7
  cluster_name = "vm-prd-retail-cluster"
  eks_cluster_version = 1.27
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access = true
  cluster_service_ipv4_cidr = "172.20.0.0/16"
  cluster_tags = var.cluster_tags

#-------------------EKS Node-----------
  node_volume_size = 30
  instance_type = "t3.medium"
  desired_size = 2
  max_size     = 2
  min_size     = 2
#--------------- Redis------------------
  user_id = "vn-redis"
  user_name = "vn-redis"
  user_id_default = "vn-default"
  access_string = "on ~* +@all"
  user_group_name = "vn-retail"
  multi_az_enabled =  true
  cluster_mode_num_node_groups = 1
  cluster_mode_replicas_per_node_group = 1
#-----------------------RDS----------------
db_instance_class = "t3.micro"
db_multi_az_enabled = false

#----------------------NLB------------------
#----------------------cloudfront-----------

}


