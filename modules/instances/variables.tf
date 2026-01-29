variable "aws_region" {
  description = "Región de AWS"
  type        = string
}

variable "ami_id" {
  description = "ID de la AMI"
  type        = string
}

variable "instance_name" {
  description = "Nombre para etiquetar la instancia"
  type        = string
}

variable "user_data_script" {
  description = "Contenido del script de inicio (sh)"
  type        = string
  default     = "" 
}


variable "key_name" {
  description = "key name"
  type        = string
  default     = "" 
}