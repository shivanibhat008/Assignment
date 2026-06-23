output "hub_lambda_sg_id" {
  description = "The Security Group ID assigned to the Central Hub Lambda functions."
  value       = aws_security_group.hub_lambda_sg.id
}

output "spoke_alb_sg_id" {
  description = "The Security Group ID assigned to the Spoke Internal ALB, restricted to Hub CIDR ingress."
  value       = aws_security_group.spoke_alb_sg.id
}

output "fargate_role_arn" {
  description = "The ARN of the IAM Execution Role assigned to the ECS Fargate tasks in the Spoke."
  value       = aws_iam_role.spoke_fargate_task.arn
}

output "lambda_role_arn" {
  description = "The ARN of the IAM Execution Role assigned to the Central Hub Lambda functions."
  value       = aws_iam_role.hub_lambda_execution.arn
}
