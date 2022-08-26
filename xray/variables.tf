variable "response_time_threshold" {
  default     = "0.10"
  description = "Threshold time that the server took to send a response."
}

variable "duration_threshold" {
  default     = "0.12"
  description = "Total request duration including all downstream calls."
}
