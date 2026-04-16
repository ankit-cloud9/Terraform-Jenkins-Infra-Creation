provider "aws" {
    region = "ap-south-1"  
}

resource "aws_instance" "instance-1" {
  ami           = "ami-07216ac99dc46a187"
  instance_type = "t2.micro"
  tags = {
      Name = "TF-Instance",
      Env = "dev"
  }
}
