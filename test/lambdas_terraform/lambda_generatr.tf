/*
Additional resource to automatically create the Generatr lambda
using existing role of Slingr lambda function.
*/

resource "aws_lambda_function" "PortChange_Generatr" {
  filename      = "PortChange_Generatr.zip"
  function_name = "${var.lambda_generatr_function_name}"
  role          = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/PortChange_Slingr_role"
  handler       = "PortChange_Generatr.lambda_handler"

  source_code_hash = "${base64sha256("PortChange_Generatr.zip")}"

  runtime = "python3.6"

  tags = {
    "purpose"    = "testing"
    "department" = "security"
  }

  depends_on = ["aws_iam_role.iam_for_lambda"]
}