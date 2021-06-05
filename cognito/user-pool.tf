resource "aws_cognito_user_pool" "pool" {
  name = "${var.project}-${var.environment}"

  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }

    # recovery_mechanism {
    #   name     = "verified_phone_number"
    #   priority = 2
    # }
  }

  auto_verified_attributes = ["email"]

  username_attributes = ["email"]
  username_configuration {
    case_sensitive = true
  }

  device_configuration {
    challenge_required_on_new_device      = true
    device_only_remembered_on_user_prompt = true
  }

  # email_configuration {
  #   email_sending_account = "DEVELOPER"
  #   # from_email_address    = var.ses_from_email
  #   # source_arn            = var.ses_arn
  # }

  email_verification_message = "Your verification code is {####}."
  email_verification_subject = "Your verification code"

  mfa_configuration = "OPTIONAL"

  password_policy {
    minimum_length    = 8
    require_lowercase = true
    require_numbers   = true
    require_symbols   = true
  }

  schema {
    name                = "email"
    attribute_data_type = "String"
    mutable             = true
    required            = true
    string_attribute_constraints {
      min_length = 0
      max_length = 2048
    }
  }

  schema {
    name                = "name"
    attribute_data_type = "String"
    mutable             = true
    required            = true
    string_attribute_constraints {
      min_length = 1
      max_length = 128
    }
  }

  schema {
    name                = "family_name"
    attribute_data_type = "String"
    mutable             = true
    required            = true
    string_attribute_constraints {
      min_length = 1
      max_length = 128
    }
  }

  schema {
    name                = "role"
    attribute_data_type = "String"
    mutable             = true
    required            = false

    string_attribute_constraints {
      min_length = 1
      max_length = 128
    }
  }

  # sms_authentication_message = "Your code is {####}"

  # sms_configuration {
  #   external_id    = "example"
  #   sns_caller_arn = aws_iam_role.example.arn
  # }

  software_token_mfa_configuration {
    enabled = true
  }

  user_pool_add_ons {
    advanced_security_mode = "ENFORCED"
  }
}
