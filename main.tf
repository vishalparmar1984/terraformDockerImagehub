provider "aws" {
  region = "ap-south-1"
}

terraform {
  backend "s3" {
    bucket = "demo-vishal-docker-setup"
    key    = "terraform/terraform.state"
    region = "ap-south-1"
  }
}

variable "docker_image" {
  description = "Docker image to deploy"
}

resource "aws_instance" "app" {
  ami           = "ami-0ad21ae1d0696ad58"  # Ubuntu AMI in ap-south-1 region
  instance_type = "t2.micro"
  key_name      = "logesh"

  user_data = <<-EOF
              #!/bin/bash
              # Update the package list
              sudo apt-get update -y
              # Install Docker
              sudo apt-get install -y docker.io
              # Start Docker service
              sudo systemctl start docker
              sudo systemctl enable docker
              # Remove existing container if it exists
              if [ $(sudo docker ps -aq -f name=myapp) ]; then
                  sudo docker stop myapp --force
                  sudo docker rm myapp --force
              fi
              # Run the Docker container
              sudo docker run -d --name myapp -p 5000:5000 ${var.docker_image}
              EOF

  tags = {
    Name = "MyAppInstance"
  }
}

output "instance_ip" {
  value = aws_instance.app.public_ip
}
