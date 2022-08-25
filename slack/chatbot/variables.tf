variable "chatbot_name" {
  type = string
}

variable "slack_channel_id" {
  type = string
}

variable "slack_workspace_id" {
  type = string
}

variable "sns_topic_arns" {
  type = list(string)
}

variable "guardrail_policies" {
  type        = list(string)
  default     = []
  description = "Allowable permissions in the channel thru chatbot"
}
