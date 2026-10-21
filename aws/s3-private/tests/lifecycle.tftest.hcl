mock_provider "aws" {
  mock_data "aws_iam_policy_document" {
    defaults = {
      json = "{\"Version\":\"2012-10-17\",\"Statement\":[]}"
    }
  }
}

run "defaults_keep_only_the_retention_rule" {
  command = plan

  variables {
    project     = "terraform-test"
    environment = "test"
    bucket_name = "terraform-test-lifecycle-defaults"
  }

  assert {
    condition     = length(aws_s3_bucket_lifecycle_configuration.main-bucket-lifecycle-rule.rule) == 1
    error_message = "Without the optional inputs only the primary-storage-class-retention rule must exist."
  }

  assert {
    condition     = aws_s3_bucket_lifecycle_configuration.main-bucket-lifecycle-rule.rule[0].id == "primary-storage-class-retention"
    error_message = "The primary-storage-class-retention rule must stay first."
  }
}

run "intelligent_tiering_and_multipart_abort_add_rules" {
  command = plan

  variables {
    project                                = "terraform-test"
    environment                            = "test"
    bucket_name                            = "terraform-test-lifecycle-tiering"
    intelligent_tiering_transition_days    = 0
    abort_incomplete_multipart_upload_days = 7
  }

  assert {
    condition = [for r in aws_s3_bucket_lifecycle_configuration.main-bucket-lifecycle-rule.rule : r.id] == [
      "primary-storage-class-retention",
      "intelligent-tiering",
      "abort-incomplete-multipart-upload",
    ]
    error_message = "Both optional rules must be added after the retention rule."
  }

  assert {
    condition     = one(aws_s3_bucket_lifecycle_configuration.main-bucket-lifecycle-rule.rule[1].transition).storage_class == "INTELLIGENT_TIERING"
    error_message = "The tiering rule must transition to INTELLIGENT_TIERING."
  }

  assert {
    condition     = aws_s3_bucket_lifecycle_configuration.main-bucket-lifecycle-rule.rule[1].filter[0].object_size_greater_than == 131072
    error_message = "The tiering rule must skip objects of 128 KiB or less by default."
  }

  assert {
    condition     = aws_s3_bucket_lifecycle_configuration.main-bucket-lifecycle-rule.rule[2].abort_incomplete_multipart_upload[0].days_after_initiation == 7
    error_message = "Incomplete multipart uploads must be aborted after the configured days."
  }
}
