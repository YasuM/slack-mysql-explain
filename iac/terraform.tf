locals {
  name      = "slack-explain"
  image_tag = "30"
}
data "aws_caller_identity" "current" {}

resource "aws_ecr_repository" "ecr" {
  name                 = local.name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}