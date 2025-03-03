variable "instance_count" {
  description = "The number of instances to launch"
  default     = 1
  type        = number
}

variable "ses_email" {
  type        = string
  default     = ""
  description = "The email address to verify for SES"
}
