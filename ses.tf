resource "aws_ses_email_identity" "verified_email" {
  email = var.ses_email
}
