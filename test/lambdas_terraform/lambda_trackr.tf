/*
Additional resource to automatically create the Trackr lambda,
Cloudwatch event rule, lambda permission to allow invocation from Cloudwatch
and Cloudwatch event target.
*/

resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.PortChange_Slack_Trackr.function_name}"
  principal     = "events.amazonaws.com"
  source_arn    = "arn:aws:events:us-east-1:${data.aws_caller_identity.current.account_id}:rule/${var.cloudwatch_rule_name}"
}

resource "aws_cloudwatch_event_rule" "PortChange_Slack_Trackr" {
  name        = "${var.cloudwatch_rule_name}"
  description = "rule used for testing ChaoSlingr notification, using its Trackr function"

  event_pattern = <<PATTERN
{
  "source": [
    "aws.ec2"
  ],
  "detail-type": [
    "AWS API Call via CloudTrail"
  ],
  "detail": {
    "eventSource": [
      "ec2.amazonaws.com"
    ],
    "eventName": [
      "AuthorizeSecurityGroupIngress",
      "RevokeSecurityGroupIngress",
      "AuthorizeSecurityGroupEgress",
      "RevokeSecurityGroupEgress"
    ]
  }
}
PATTERN
}

resource "aws_cloudwatch_event_target" "target" {
  rule = "${aws_cloudwatch_event_rule.PortChange_Slack_Trackr.name}"
  arn  = "${aws_lambda_function.PortChange_Slack_Trackr.arn}"
}

resource "aws_lambda_function" "PortChange_Slack_Trackr" {
  filename      = "PortChange_Slack_Trackr.zip"
  function_name = "${var.lambda_trackr_function_name}"
  # uses the existing role of the PortChange_Slingr lambda function
  role    = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/PortChange_Slingr_role"
  handler = "${var.lambda_trackr_function_name}.lambda_handler"

  source_code_hash = "${base64sha256("PortChange_Slack_Trackr.zip")}"

  runtime = "python3.6"

  # change these as needed
  environment {
    variables = {
      channel = "test-chaoslingr",
      hook    = "INSERT-YOUR-SLACK-INCOMING-WEBHOOK-HERE"
    }
  }

  tags = {
    "purpose"    = "testing"
    "department" = "security"
  }

  depends_on = ["aws_iam_role.iam_for_lambda"]
}
