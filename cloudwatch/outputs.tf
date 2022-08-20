output "sns_topic_arn" {
  value = length(module.chatbot) > 0 ? module.chatbot[0].sns_topic_arn : var.sns_topic_arn
}
