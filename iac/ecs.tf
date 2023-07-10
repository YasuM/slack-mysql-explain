resource "aws_cloudwatch_log_group" "log" {
  name              = "/ecs/slack-app"
  retention_in_days = 30
}

resource "aws_ecs_cluster" "this" {
  name = "slack-app-cluster"
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_service" "service" {
  name             = "slack-app"
  cluster          = aws_ecs_cluster.this.id
  task_definition  = aws_ecs_task_definition.service.arn
  launch_type      = "FARGATE"
  platform_version = "LATEST"


  desired_count = 1
  network_configuration {
    assign_public_ip = true
    subnets          = [aws_subnet.public_subnet_1a.id, aws_subnet.public_subnet_1c.id]
  }
}

resource "aws_ecs_task_definition" "service" {
  family                   = "service"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.role.arn
  task_role_arn            = aws_iam_role.role.arn
  container_definitions = jsonencode([
    {
      name      = "slack-explain"
      image     = "${aws_ecr_repository.ecr.repository_url}:${local.image_tag}"
      cpu       = 256
      memory    = 512
      essential = true
      secrets = [
        {
          "name" : "SLACK_BOT_TOKEN",
          "valueFrom" : aws_ssm_parameter.slack_bot_token.name
        },
        {
          "name" : "SLACK_APP_TOKEN",
          "valueFrom" : aws_ssm_parameter.slack_app_token.name
        },
        {
          "name" : "SLACK_SIGNING_SECRET",
          "valueFrom" : aws_ssm_parameter.slack_signing_secret.name
        }

      ]
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-region : "ap-northeast-1"
          awslogs-group : aws_cloudwatch_log_group.log.name
          awslogs-stream-prefix : "ecs"
        }
      }
    },
  ])
}