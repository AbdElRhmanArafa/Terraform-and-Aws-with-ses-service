resource "aws_instance" "test" {
  count         = var.instance_count
  ami           = "ami-07f9449c0b700566e"
  instance_type = "t2.micro"
  tags = {
    Name = "test-instance${count.index}"
  }
}