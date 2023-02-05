variable "instances" {
  default = {
    "instance_type" = "t2.micro"
  }
}


variable "security_groups" {
  default = [80, 443]
}

variable "igw" {
  default = "myinternetgateway"
}

variable "instance_count" {
  default = 2
}

variable "subnet_cidr" {
  type    = list(any)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "availability_zone" {
  type        = list(any)
  default     = ["eu-west-2a", "eu-west-2b"]
  description = "my availability zones"
}

variable "subnet" {
  default = ["mysubnet1", "mysubnet2"]
}

variable "domain" {
  type = map(string)
  default = {
    domain_name = "davidaltschool.me"
    subdomain   = "terraform-test.davidaltschool.me"
  }
}

variable "lb" {
  type        = string
  default     = "myalb"
  description = "application load balancer"
}

variable "vpc_cidr" {
  type        = string
  default     = "10.0.0.0/16"
  description = "vpc cidr"
}

