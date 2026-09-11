variable "prefix" {
  type        = string
  description = "Prefix para el entorno de desarrollo"
}

variable "project-code" {
  type        = string
  description = "Codigo del proyecto para nombres de recursos"
}

variable "rg-name" {
  type        = string
  description = "Nombre del grupo de recursos en Azure"
}

variable "debian-user" {
  type        = string
  description = "Nombre de usuario para la VM"
}



variable "rg-kv-name" {
  type        = string
  description = "Nombre del grupo de recursos de la KV SSH"
}

variable "kv-ssh-name" {
  type        = string
  description = "Nombre de la KV con llaves SSH"
}

variable "kv-ssh-secret" {
  type        = string
  description = "Nombre del secretto SSH"
}

