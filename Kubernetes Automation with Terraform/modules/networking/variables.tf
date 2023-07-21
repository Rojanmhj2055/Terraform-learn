
variable "env_prefix"{
}
variable "vpc_cidr_block" {
  default = "10.0.0.0/16"
}
variable "subnet_cidr_blocks" {
    type = list(string)

    validation {
      condition = length(var.subnet_cidr_blocks)>3
      error_message = "Must have 4 subnet cidr blocks"
    }
}

variable "avail_zone" {}