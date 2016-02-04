variable "aws_cidrs" {
  default = {
    vpc     = "10.10.0.0/16"
    subnet  = "10.10.1.0/24"
  }
}
