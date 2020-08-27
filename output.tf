/* output "sp_password" {
  value = module.service_principal.principal_pw
  sensitive = true
} */

output "display_name" {
  description = "The Display Name of the Azure Active Directory Application associated with this Service Principal."
  value       = module.service_principal.service_principal_id.display_name
}

output "application_id" {
  description = "Application ID (appId) for the Service Principal"
  value       = module.service_principal.service_principal_id.application_id 
}

output "object_id" {
  description = "The Service Principal's Object ID"
  value       = module.service_principal.service_principal_id.object_id
}

/* output "login_server" {
  description = "The URL that can be used to log into the container registry."
  value       = module.service_principal
} */

/* output "admin_username" {
  description = "The Username associated with the Container Registry Admin account - if the admin account is enabled."
  value       = module.trg_acr.admin_username
}

output "admin_password" {
  description = "The Password associated with the Container Registry Admin account - if the admin account is enabled."
  value       = module.trg_acr.admin_password
} */