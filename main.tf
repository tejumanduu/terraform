provider "aws" {
  region = "us-east-1"  # Replace with your preferred AWS region
}

resource "aws_instance" "example" {
  ami           = "ami-09538990a0c4fe9be"  
  instance_type = "t2.micro"             
  key_name      = "777.pem"   
  tags = {
    Name = "MyEC2Instance"
  }
}
