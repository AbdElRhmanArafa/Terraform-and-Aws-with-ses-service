terraform {
  backend "s3" {
    bucket = "iti-alter-project"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }

}
