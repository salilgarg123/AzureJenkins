##### Application Variables #####
variable "application_name" {
  description = "The display name for the application"
  default = "Optimize Insights ACR Prod"
}

##### Service Principal Variables #####
/* variable "tags" {
  description = "A list of tags to apply to the Service Principal"
  default     = "Standard"
} */

##### Service Principal Password Variables #####

variable "description" {
  description = "A description for the Password"
  default     = "Password for ACR"
}

variable "value" {
  description = "Password for this Service Principal"
  default     = "Password123"
}

variable "end_date_relative" {
  description = "End Date which the Password is valid until"
  default     = "17520h"
}