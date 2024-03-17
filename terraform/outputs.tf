output "vpc_eu_west_1_id" {
  value       = module.vpc_eu_west_1.vpc_id
  description = "The ID of the VPC in the eu-west-1 region."
}

output "vpc_eu_west_2_id" {
  value       = module.vpc_eu_west_2.vpc_id
  description = "The ID of the VPC in the eu-west-2 region."
}

output "iam_role_arn" {
  value       = module.iam_example.role_arn
  description = "The ARN of the IAM role created."
}

output "ec2_instance_ids" {
  value       = module.ec2_nginx.instance_ids
  description = "The IDs of the EC2 instances running Nginx."
}

output "alb_dns_name" {
  value       = module.load_balancer.alb_dns_name
  description = "The DNS name of the Application Load Balancer."
}

output "cloudfront_distribution_id" {
  value       = module.cloudfront_distribution.cloudfront_distribution_id
  description = "The ID of the CloudFront distribution."
}

output "cloudfront_distribution_domain" {
  value       = module.cloudfront_distribution.cloudfront_distribution_domain
  description = "The domain name of the CloudFront distribution."
}

output "logging_monitoring_cloudtrail_id" {
  value       = module.logging_monitoring.cloudtrail_id
  description = "The ID of the CloudTrail trail."
}

output "logging_monitoring_cloudwatch_log_group_name" {
  value       = module.logging_monitoring.cloudwatch_log_group_name
  description = "The name of the CloudWatch Log Group."
}
