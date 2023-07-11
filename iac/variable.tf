data "aws_caller_identity" "current" {}

locals {
  name      = "slack-explain"
  image_tag = "30"
}