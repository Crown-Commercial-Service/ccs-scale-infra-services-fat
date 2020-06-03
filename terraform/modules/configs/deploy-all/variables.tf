variable "aws_account_id" {
  type = string
}

variable "environment" {
  type = string
}

variable "ecr_image_id_fat_buyer_ui" {
  type = string
  default = "9687b45-candidate"
}
