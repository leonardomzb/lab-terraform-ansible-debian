# Prefix y codigo para crear el nombre de recursos EJ: vnet-dev-terra-ansible-01
prefix       = "dev"
project-code = "terra-ansible"
# Nombre de grupo de recursos
rg-name = "rg-terra-ansible"
# Nombre de usuario usado al crear la VM
debian-user = "debianadmin"


# Grupo de recursos de Azure Key vault 
rg-kv-name = "rg-key-vault"
# Azure Key vault con llaves publica y privada para acceso SSH necesario para Ansible
kv-ssh-name = "kv-learn-labs"
# Nombre de secreto con llave privada
kv-ssh-secret = "debian-server-key"


# Usar el siguiente comando para guardar el contenido de la SSH key privada en azure y no perder formato (PowerShell)

# az keyvault secret set `
#   --vault-name "nombre_key_vault" `
#   --name "nombre_de_secreto" `
#   --file ".\nombre_de_archivo_key_ssh_privada"
