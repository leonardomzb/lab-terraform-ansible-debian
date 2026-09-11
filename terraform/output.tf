# terraform output -json

# 1. Obtener el ID de la VNet creada por el módulo
output "vnet_id" {
  value       = module.vnet.resource_id
  description = "El ID único de la Virtual Network en Azure"
}

# 2. Obtener el nombre de la VNet
output "vnet_name" {
  value       = module.vnet.name
  description = "El nombre de la Virtual Network"
}

# 3. Obtener los IDs de todas las subredes creadas
output "subnet_ids" {
  value       = module.vnet.subnets
  description = "Mapa con toda la información y los IDs de las subredes creadas"
}

output "pip_vm" {
  value       = module.debian_vm.virtual_machine_azurerm.public_ip_address
  description = "La dirección IP pública asignada a la máquina virtual Debian."
}
