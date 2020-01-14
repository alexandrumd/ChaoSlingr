/*
Additional resource to automatically create the needed lambdas
and corresponding role and logging policy
*/

resource "aws_iam_role" "iam_for_lambda" {
  name = "${var.iam_for_lambda_slingr_name}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_cloudwatch_log_group" "PortChange_Slingr_log_group" {
  name              = "/aws/lambda/${var.lambda_slingr_function_name}"
  retention_in_days = 7
}

resource "aws_iam_policy" "lambda_policy" {
  name        = "${var.lambda_slingr_function_name}"
  path        = "/"
  description = "Test - IAM policy to be used for ChaoSlingr lambdas"

  /* 
  You may want to change this policy as needed for the region.
  Permissions details:
  - logging - to have the corresponding Cloudwatch log group
  - ec2:AuthorizeSecurityGroupIngress - needed by Slingr lambda
  - ec2:DescribeSecurityGroups, ec2:DescribeSecurityGroupReferences, lambda:InvokeFunction - needed by Generatr lambda
  */
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "logs:CreateLogGroup",
      "Resource": "arn:aws:logs:us-east-1:${data.aws_caller_identity.current.account_id}:*",
      "Effect": "Allow"
    },
    {
        "Action": [
            "logs:CreateLogStream",
            "logs:PutLogEvents"
        ],
        "Resource": "arn:aws:logs:us-east-1:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${var.lambda_slingr_function_name}:*",
        "Effect": "Allow"
    },
    {
        "Action": "ec2:AuthorizeSecurityGroupIngress",
        "Resource": "arn:aws:ec2:us-east-1:${data.aws_caller_identity.current.account_id}:security-group/sg*",
        "Effect": "Allow"
    },
    {
        "Action": [
            "ec2:DescribeSecurityGroups",
            "ec2:DescribeSecurityGroupReferences"
        ],
        "Resource": "*",
        "Effect": "Allow"
    },
    {
        "Action": "lambda:InvokeFunction",
        "Resource": "arn:aws:lambda:us-east-1:${data.aws_caller_identity.current.account_id}:function:${var.lambda_slingr_function_name}",
        "Effect": "Allow"
    }
  ] 
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_iam" {
  role       = "${aws_iam_role.iam_for_lambda.name}"
  policy_arn = "${aws_iam_policy.lambda_policy.arn}"
}

resource "aws_lambda_function" "PortChange_Slingr" {
  filename      = "PortChange_Slingr.zip"
  function_name = "${var.lambda_slingr_function_name}"
  role          = "${aws_iam_role.iam_for_lambda.arn}"
  handler       = "PortChange_Slingr.lambda_handler"
  tags = {
    "purpose"    = "testing"
    "department" = "security"
  }

  source_code_hash = "${base64sha256("PortChange_Slingr.zip")}"

  runtime = "python3.6"

  depends_on = ["aws_iam_role_policy_attachment.lambda_iam", "aws_cloudwatch_log_group.PortChange_Slingr_log_group"]
}
