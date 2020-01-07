# Common inputs used across modules

variable "default_tags" { default = {} }

variable "default_tags_true_tag" { default = {} }

variable "default_tags_false_tag" { default = {} }

variable "lambda_function_name" { default = "PortChange_Generatr" }

variable "iam_for_lambda_name" { default = "PortChange_Generatr_role" }

variable "lambda_slingr_function_name" { default = "PortChange_Slingr" }
