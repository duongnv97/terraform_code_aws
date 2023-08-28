data "aws_kms_key" "kms_cmk" {
  depends_on = [
    aws_kms_key.kms_cmk
  ]
  key_id = aws_kms_key.kms_cmk.arn
}

resource "aws_kms_alias" "kms_alias" {
  name          = format("alias/%s", local.general_prefix)
  target_key_id = aws_kms_key.kms_cmk.key_id
}

resource "aws_kms_key" "kms_cmk" {
  depends_on = [
    aws_iam_service_linked_role.autoscaling
  ]
  description                = "Custome Manager KMS Key"
  deletion_window_in_days    = 7
  enable_enable_key_rotation = true
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "Allow Cloudwatch for cmk",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : [
            "cloudwatch.amazon.com",
            "event.amazonaws.com",
            "*"
          ]
        },
        "Action" : [
          "kms:Decrypt", "kms:GenerateDataKey*",
          "*"
        ]
        "Resource" : "*"
      },
      {
        "Sid" : "Enable IAM User Permissions",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        "Action" : "kms:*",
        "Resource" : "*"
      },
      {
        "Sid" : "Allow access for Key Administrators",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"
        },
        "Action" : [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:Describe*"
        ],
        "Resource" : "*"
      },
      {
        "Sid" : "Allow attachment of perssistent resource",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"
        },
        "Action" : "kms:CreateGrant",
        "Resource" : "*"
        "Condition" : {
          "Bool" : {
            "kms:GrantIsForAWSResource" : "true"
          }
        }
      },
      {
        "Sid" : "Allow usage by CW  Logs",
        "Effect" : "Allow",
        "Principal" : {
          "AWServiceS" : "logs${data.aws_region.current.name}.amazonaws.com"
        },
        "Action" : [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:Describe*"
        ],
        "Resource" : "*"
        "Condition" : {
          "ArnLike" : {
            "kms:EncryptionContext:aws:logs:arn" : "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:*"
          }
        }
      }
    ]
  })
  tags = {
    "Name" = format("%s-kms", local.general_prefix)
  }
}

resource "aws_iam_service_linked_role" "autoscaling" {
  aws_service_name = "autoscaling.amazonaws.com"
}