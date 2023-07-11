resource "aws_iam_role" "role" {
  name = local.name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })
  managed_policy_arns = ["arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"]
}

resource "aws_iam_policy" "policy" {
  name = local.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = ["ssm:GetParameters"]
        Effect = "Allow"
        Resource = [
          "arn:aws:ssm:ap-northeast-1:223755632708:parameter/${aws_ssm_parameter.slack_signing_secret.name}",
          "arn:aws:ssm:ap-northeast-1:223755632708:parameter/${aws_ssm_parameter.slack_app_token.name}",
          "arn:aws:ssm:ap-northeast-1:223755632708:parameter/${aws_ssm_parameter.slack_bot_token.name}",

        ]
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach" {
  role       = aws_iam_role.role.name
  policy_arn = aws_iam_policy.policy.arn
}