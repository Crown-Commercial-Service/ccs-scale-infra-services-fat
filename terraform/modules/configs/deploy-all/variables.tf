variable "aws_account_id" {
  type = string
}

variable "environment" {
  type = string
}

variable "ecr_image_id_fat_buyer_ui" {
  type = string
  default = "e909a8e-candidate"
}
