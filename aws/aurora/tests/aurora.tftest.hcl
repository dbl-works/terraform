mock_provider "aws" {
  mock_data "aws_iam_policy_document" {
    defaults = {
      json = "{\"Version\":\"2012-10-17\",\"Statement\":[]}"
    }
  }

  mock_data "aws_caller_identity" {
    defaults = {
      account_id = "123456789012"
    }
  }
}

variables {
  vpc_id      = "vpc-12345678"
  subnet_ids  = ["subnet-11111111", "subnet-22222222"]
  kms_key_arn = "arn:aws:kms:eu-central-1:123456789012:key/12345678-1234-1234-1234-123456789012"
  project     = "squake"
  environment = "staging"
  password    = "test-password-only"
}

run "legacy_default_serverless" {
  command = plan

  variables {
    instance_count = 2
    instance_class = "db.serverless"
  }

  assert {
    condition     = length(aws_rds_cluster_instance.cluster_instances) == 2
    error_message = "Expected 2 cluster instances from instance_count."
  }

  assert {
    condition     = aws_rds_cluster_instance.cluster_instances[0].instance_class == "db.serverless" && aws_rds_cluster_instance.cluster_instances[0].promotion_tier == 0
    error_message = "Expected instance 0 to use db.serverless with promotion_tier 0."
  }

  assert {
    condition     = aws_rds_cluster_instance.cluster_instances[1].instance_class == "db.serverless" && aws_rds_cluster_instance.cluster_instances[1].promotion_tier == 0
    error_message = "Expected instance 1 to use db.serverless with promotion_tier 0."
  }

  assert {
    condition     = length(aws_rds_cluster.main.serverlessv2_scaling_configuration) == 1
    error_message = "Expected 1 serverlessv2_scaling_configuration block for serverless instances."
  }
}

run "storage_type_io_optimized" {
  command = plan

  variables {
    storage_type = "aurora-iopt1"
  }

  assert {
    condition     = aws_rds_cluster.main.storage_type == "aurora-iopt1"
    error_message = "Expected storage_type to be aurora-iopt1."
  }
}

run "mixed_rolling_cutover" {
  command = plan

  variables {
    instances = [
      { instance_class = "db.serverless", promotion_tier = 2 },
      { instance_class = "db.serverless", promotion_tier = 2 },
      { instance_class = "db.t4g.medium", promotion_tier = 1 },
    ]
  }

  assert {
    condition     = length(aws_rds_cluster_instance.cluster_instances) == 3
    error_message = "Expected 3 cluster instances during mixed cutover."
  }

  assert {
    condition     = aws_rds_cluster_instance.cluster_instances[0].instance_class == "db.serverless" && aws_rds_cluster_instance.cluster_instances[0].promotion_tier == 2
    error_message = "Expected instance 0 to be db.serverless at tier 2."
  }

  assert {
    condition     = aws_rds_cluster_instance.cluster_instances[1].instance_class == "db.serverless" && aws_rds_cluster_instance.cluster_instances[1].promotion_tier == 2
    error_message = "Expected instance 1 to be db.serverless at tier 2."
  }

  assert {
    condition     = aws_rds_cluster_instance.cluster_instances[2].instance_class == "db.t4g.medium" && aws_rds_cluster_instance.cluster_instances[2].promotion_tier == 1
    error_message = "Expected instance 2 to be db.t4g.medium at tier 1."
  }

  assert {
    condition     = length(aws_rds_cluster.main.serverlessv2_scaling_configuration) == 1
    error_message = "Expected serverlessv2_scaling_configuration while any db.serverless instance exists."
  }
}

run "pure_provisioned_omits_scaling_configuration" {
  command = plan

  variables {
    instances = [
      { instance_class = "db.r8g.xlarge" },
      { instance_class = "db.r8g.2xlarge", promotion_tier = 1 },
    ]
  }

  assert {
    condition     = length(aws_rds_cluster_instance.cluster_instances) == 2
    error_message = "Expected 2 provisioned cluster instances."
  }

  assert {
    condition     = aws_rds_cluster_instance.cluster_instances[0].instance_class == "db.r8g.xlarge" && aws_rds_cluster_instance.cluster_instances[0].promotion_tier == 0
    error_message = "Expected instance 0 to be db.r8g.xlarge with default promotion_tier 0."
  }

  assert {
    condition     = aws_rds_cluster_instance.cluster_instances[1].instance_class == "db.r8g.2xlarge" && aws_rds_cluster_instance.cluster_instances[1].promotion_tier == 1
    error_message = "Expected instance 1 to be db.r8g.2xlarge at tier 1."
  }

  assert {
    condition     = length(aws_rds_cluster.main.serverlessv2_scaling_configuration) == 0
    error_message = "Expected 0 serverlessv2_scaling_configuration blocks for pure provisioned cluster."
  }
}

run "rejects_invalid_storage_type" {
  command = plan

  variables {
    storage_type = "gp3"
  }

  expect_failures = [
    var.storage_type,
  ]
}

run "rejects_empty_instances" {
  command = plan

  variables {
    instances = []
  }

  expect_failures = [
    var.instances,
  ]
}

run "rejects_blank_instance_class" {
  command = plan

  variables {
    instances = [
      { instance_class = " " },
    ]
  }

  expect_failures = [
    var.instances,
  ]
}

run "rejects_out_of_range_promotion_tier" {
  command = plan

  variables {
    instances = [
      { instance_class = "db.r8g.xlarge", promotion_tier = 16 },
    ]
  }

  expect_failures = [
    var.instances,
  ]
}

run "rejects_fractional_promotion_tier" {
  command = plan

  variables {
    instances = [
      { instance_class = "db.r8g.xlarge", promotion_tier = 1.5 },
    ]
  }

  expect_failures = [
    var.instances,
  ]
}
