terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = var.aws_region_eu_west_1
  alias  = "eu-west-1"
}

provider "aws" {
  region = var.aws_region_eu_west_2
  alias  = "eu-west-2"
}

# Kubernetes provider configuration
provider "kubernetes" {
  # Configuration details here...
}

module "vpc_eu_west_1" {
  source     = "./modules/vpc"
  cidr_block = var.region_eu_west_1_cidr_block
  # Additional configuration...
}

module "eks" {
  source        = "./modules/eks"
  cluster_name  = var.cluster_name
  ami_id        = var.ami_id
  instance_type = var.instance_type
  # Additional configuration...
}

# VPC resources for eu-west-1
resource "aws_vpc" "vpc_eu_west_1" {
  provider = aws.eu-west-1
  cidr_block           = var.region_eu_west_1_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "VPC in eu-west-1"
  }
}

# VPC resources for eu-west-2
resource "aws_vpc" "vpc_eu_west_2" {
  provider = aws.eu-west-2
  cidr_block           = var.region_eu_west_2_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "VPC in eu-west-2"
  }
}

module "eks" {
  source           = "./modules/compute/eks"
  providers        = { aws = aws.eu-west-2 }
  cluster_name     = var.cluster_name
  subnet_ids       = module.vpc_eu_west_2.subnet_ids
  eks_version      = var.eks_version  # Correctly passing Kubernetes version
  node_group_name  = var.node_group_name
  node_desired_size = var.node_desired_size
  node_max_size    = var.node_max_size
  node_min_size    = var.node_min_size
}


# ALB module assuming use in eu-west-2 or adjust as needed
module "alb" {
  source              = "./modules/load_balancers"
  providers           = { aws = aws.eu-west-2 }
  alb_security_groups = [aws_security_group.alb_sg.id] # Example value, replace as necessary
  alb_subnets         = module.vpc_eu_west_2.public_subnet_ids # Assuming subnet IDs are outputted by the VPC module
  vpc_id              = module.vpc_eu_west_2.vpc_id # Assuming the VPC ID is outputted by the VPC module
}


# Assuming additional configurations for security groups, EC2 instances, etc., are defined elsewhere.
module "ec2_instances" {
  source                = "./modules/compute/ec2"
  ami_id                = var.ami_id
  instance_type         = var.instance_type
  subnet_ids            = module.vpc_eu_west_2.public_subnet_ids # Adjust based on actual output from your VPC module
  key_name              = var.key_name
  security_group_ids    = [module.alb.alb_security_group_id] # Assuming ALB's SG is to be used, adjust as needed
  iam_instance_profile_arn = var.iam_instance_profile_arn
}

module "cloudfront_distribution" {
  source       = "./modules/cloudfront"
  alb_dns_name = module.alb.alb_dns_name  # Example of passing ALB DNS name to the module
}



# Call the logging_monitoring module and pass the variables
module "logging_monitoring" {
  source = "./modules/logging_monitoring"

  cloudtrail_name             = var.cloudtrail_name
  s3_bucket_name              = var.s3_bucket_name
  cloudwatch_log_group_name   = var.cloudwatch_log_group_name
  metric_filter_name          = var.metric_filter_name
  metric_filter_pattern       = var.metric_filter_pattern
  subscription_filter_name    = var.subscription_filter_name
  subscription_filter_pattern = var.subscription_filter_pattern
  sns_topic_name              = var.sns_topic_name
  metric_alarm_name           = var.metric_alarm_name
}



module "subnets" {
  source                      = "./modules/network/subnets"
  
  # Variables for eu-west-1
  vpc_id_eu_west_1            = module.vpc_eu_west_1.vpc_id
  public_cidr_block_eu_west_1 = var.public_cidr_block_eu_west_1
  private_cidr_block_eu_west_1= var.private_cidr_block_eu_west_1
  availability_zone_eu_west_1 = var.availability_zone_eu_west_1
  
  # Variables for eu-west-2
  vpc_id_eu_west_2            = module.vpc_eu_west_2.vpc_id
  public_cidr_block_eu_west_2 = var.public_cidr_block_eu_west_2
  private_cidr_block_eu_west_2= var.private_cidr_block_eu_west_2
  availability_zone_eu_west_2 = var.availability_zone_eu_west_2
}




module "iam_roles" {
  source  = "./modules/security/iam"
  
  eks_node_role_name         = "eks-node-role"
  eks_cluster_role_name      = "eks-cluster-role"
  custom_role_name           = "solitics-example_role"
  custom_policy_name         = "solitics-example_policy"
  custom_policy_document     = var.custom_policy_document # This should be defined in your variables.tf
  s3_bucket_for_policy       = "solitics-example-bucket" # Assume you have a variable or hard-coded value for this
}


module "nacls" {
  source   = "./modules/security/nacls"
  vpc_id   = var.vpc_id # Assuming you have a VPC ID to pass here
}



