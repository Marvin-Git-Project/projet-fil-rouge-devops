# Sorties Terraform - IPs des serveurs crees

output "ip_app_pgadmin" {
  description = "IP publique du serveur app+pgAdmin"
  value       = aws_instance.app_pgadmin.public_ip
}

output "ip_odoo" {
  description = "IP publique du serveur Odoo"
  value       = aws_instance.odoo.public_ip
}
