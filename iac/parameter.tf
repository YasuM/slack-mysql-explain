resource "aws_ssm_parameter" "slack_signing_secret" {
  name  = "slack_signing_secret"
  type  = "String"
  value = "dummy"
}

resource "aws_ssm_parameter" "slack_app_token" {
  name  = "slack_app_token"
  type  = "String"
  value = "dummy"
}

resource "aws_ssm_parameter" "slack_bot_token" {
  name  = "slack_bot_token"
  type  = "String"
  value = "dummy"
}