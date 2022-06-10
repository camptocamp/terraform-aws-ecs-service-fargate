variable "app_name" {
  type = string
}

variable "app_environment" {
  type    = string
  default = "prod"
}

variable "aws_region" {
  type    = string
  default = "eu-west-1"
}

variable "vpc_id" {}

variable "ecs_cluster_id" {}

variable "subnet_private_ids" {
  type = list(string)
}

variable "subnet_public_ids" {
  type = list(string)
}

variable "task_ressources_cpu" {
  type    = string
  default = 256
}

variable "task_ressources_memory" {
  type    = string
  default = 512
}

variable "task_network_mode" {
  type    = string
  default = "awsvpc"
}

variable "task_definition" {
  description = "The task definition to use for the task"
}

variable "task_desired_count" {
  type    = number
  default = 1
}

variable "task_lb_container_port" {
  type    = number
  default = 8080
}

variable "generate_public_ip" {
  type    = bool
  default = false
}
