variable "avail_zone"{
    type = list(string)
}
variable "env_prefix" {}
variable "my_ip" {}
variable "vpc_cidr_block" {}
variable "subnet_cidr_blocks" {
    type = list(string)
}

