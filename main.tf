provider "aws" {
  region = "us-east-1"  # Replace with your preferred AWS region
}

resource "aws_instance" "example" {
  ami           = "ami-0c55b159cbfafe1f0"  # Replace with the desired AMI ID
  instance_type = "t2.micro"              # Replace with the desired instance type
  key_name      = "777.pem"    # Replace with the name of your existing key pair
  
  tags = {
    Name = "MyEC2Instance"
  }
}
