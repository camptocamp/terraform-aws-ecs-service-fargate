variable "app_name" {
  type = string
}

variable "app_environment" {
  type    = string
  default = "prod"
}

variable "dns_zone" {
  type    = string
  default = ""
}

variable "dns_host" {
  type    = string
  default = ""
}

variable "aws_region" {
  type    = string
  default = "eu-west-1"
}

variable "vpc_id" {}

variable "vpc_cidr_blocks" {}

variable "ecs_cluster_id" {}

variable "subnet_private_ids" {
  type = list(string)
}

variable "subnet_public_ids" {
  type = list(string)
}

variable "service_registries" {
  type = list(object(
    {
      registry_arn = string
    }
  ))
  default = []
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

variable "task_definition_revision" {
  description = "The task definition revision to use for the task. If empty the service will always use the latest version."
  default     = ""
}

variable "task_desired_count" {
  type    = number
  default = 1
}

variable "task_lb_container_port" {
  type    = number
  default = 8080
}

variable "task_lb_container_name" {
  type    = string
  default = ""
}

variable "task_lb_custom_certificate_arn" {
  type    = string
  default = ""
}

variable "task_lb_healthcheck" {
  type = object(
    {
      enabled = bool
      matcher = string
      path    = string
      port    = number
    }
  )
  default = {
    enabled = true
    matcher = "200"
    path    = "/"
    port    = 8080
  }
}

variable "generate_public_ip" {
  type    = bool
  default = false
}
