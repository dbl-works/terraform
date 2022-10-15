variable "response_time_threshold" {
  type        = number
  default     = 0.10
  description = "Threshold time that the server took to send a response."
}

variable "duration_threshold" {
  type        = number
  default     = 0.12
  description = "Total request duration including all downstream calls."
}
