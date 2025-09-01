resource "aws_ssm_parameter" "jenkins" {
  name  = "/${var.project}/${var.environment}/jenkins"
  type  = "String"
  value = aws_security_group.jenkins.id
}