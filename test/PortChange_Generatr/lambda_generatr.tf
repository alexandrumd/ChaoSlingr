resource "aws_iam_role" "iam_for_lambda" {
  name = "${var.iam_for_lambda_name}"

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

resource "aws_cloudwatch_log_group" "PortChange_Generatr_log_group" {
  name              = "/aws/lambda/${var.lambda_function_name}"
  retention_in_days = 7
}

resource "aws_iam_policy" "lambda_logging" {
  name        = "${var.lambda_function_name}"
  path        = "/"
  description = "IAM policy for logging from a test lambda used for ChaoSlingr"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "logs:CreateLogGroup",
      "Resource": "arn:aws:logs:us-east-1:084720738044:*",
      "Effect": "Allow"
    },
    {
        "Action": [
            "logs:CreateLogStream",
            "logs:PutLogEvents"
        ],
        "Resource": "arn:aws:logs:us-east-1:084720738044:log-group:/aws/lambda/${var.lambda_function_name}:*",
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
        "Resource": "arn:aws:lambda:us-east-1:084720738044:function:${var.lambda_slingr_function_name}",
        "Effect": "Allow"
    }
  ] 
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = "${aws_iam_role.iam_for_lambda.name}"
  policy_arn = "${aws_iam_policy.lambda_logging.arn}"
}

resource "aws_lambda_function" "PortChange_Generatr" {
  filename      = "PortChange_Generatr.zip"
  function_name = "${var.lambda_function_name}"
  role          = "${aws_iam_role.iam_for_lambda.arn}"
  handler       = "PortChange_Generatr.lambda_handler"

  source_code_hash = "${base64sha256("PortChange_Generatr.zip")}"

  runtime = "python3.6"

  depends_on = ["aws_iam_role_policy_attachment.lambda_logs", "aws_cloudwatch_log_group.PortChange_Generatr_log_group"]
}