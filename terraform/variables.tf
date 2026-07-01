# Variables du projet IC GROUP

variable "aws_region" {
  description = "Region AWS"
  default     = "eu-west-3"
}

variable "ami_id" {
  description = "AMI Ubuntu 24.04 LTS (eu-west-3)"
  default     = "ami-0e207c18bb303cc68"
}

variable "key_name" {
  description = "Nom de la paire de cles SSH sur AWS"
  default     = "projet-fil-rouge-key"
}
