output "id" {
  description = "id of budget. Same as name"
  value       = aws_budgets_budget.main.id
}

output "arn" {
  description = "The ARN of the budget"
  value       = aws_budgets_budget.main.arn
}
