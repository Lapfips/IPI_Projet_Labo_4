# **`Terraform`**

## **Présentation**

**`Terraform`** est un outil open source de **`Infrastructure as Code (IaC)`** développé par HashiCorp. Il permet de définir, créer, modifier et détruire une infrastructure complète (serveurs, réseaux, stockage, etc.) en utilisant des fichiers de configuration déclaratifs au format **`HCL`** (HashiCorp Configuration Language).

Terraform gère l'état de l'infrastructure et peut s'intégrer avec de nombreux fournisseurs de cloud et d'infrastructure (AWS, Azure, Google Cloud, Proxmox, VMware, etc.).

## **Objectif d'utilisation**

Dans ce projet, Terraform est utilisé pour :

- **Provisionner l'infrastructure** : Créer automatiquement les machines virtuelles dans Proxmox
- **Configuration reproductible** : Définir l'infrastructure une seule fois et la reproduire identiquement
- **Gestion déclarative** : Décrire l'état désiré de l'infrastructure plutôt que les étapes pour l'atteindre
- **Versioning** : Garder l'infrastructure sous contrôle de version (Git)
- **Intégration avec Ansible** : Créer l'infrastructure avec Terraform puis la configurer avec Ansible

## **Ressources nécessaires**

| Ressource         | Description                                           |
| ----------------- | ----------------------------------------------------- |
| Terraform CLI     | Outil ligne de commande Terraform                     |
| Proxmox VE        | Infrastructure cible pour provisionner les VM         |
| Accès API Proxmox | Clé API pour l'authentification                       |
| Linux/Mac/Windows | Environnement de développement                        |
| Git (optionnel)   | Pour verser l'infrastructure sous contrôle de version |
| Éditeur de code   | VS Code, vim, nano, etc.                              |

Avant de commencer :

- Terraform installé localement
- Accès à une instance Proxmox fonctionnelle
- Créer un utilisateur API Proxmox avec les permissions nécessaires

## **Installation**

### **Installation de Terraform**

#### **Sur Debian/Ubuntu**

```bash
# Ajouter le dépôt HashiCorp
curl https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"

# Installer Terraform
sudo apt update
sudo apt install terraform
```

#### **Sur AlmaLinux/RedHat**

```bash
# Ajouter le dépôt HashiCorp
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo

# Installer Terraform
sudo dnf install terraform
```

#### **Sur macOS**

```bash
# Avec Homebrew
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
```

#### **Validation de l'installation**

```bash
terraform version
```

### **Configuration du provider Proxmox**

Créer un répertoire pour le projet Terraform :

```bash
mkdir terraform-lab
cd terraform-lab
```

Créer les fichiers de configuration :

```bash
# Fichier provider et variables
touch provider.tf variables.tf outputs.tf main.tf
```

## **Configuration**

### **1. Configuration du provider - `provider.tf`**

```hcl
terraform {
  required_providers {
    proxmox = {
      source = "Telmate/proxmox"
      version = "~> 2.9.14"
    }
  }
}

provider "proxmox" {
  pm_api_url      = "https://192.168.125.1:8006/api2/json"
  pm_api_token_id = "terraform@pam!terraform"
  pm_api_token_secret = "YOUR_API_TOKEN_HERE"

  pm_tls_insecure = true  # Pour certificats autosignés (à adapter en production)
  pm_log_enable   = true
  pm_log_file     = "terraform-plugin-proxmox.log"
}
```

### **2. Définition des variables - `variables.tf`**

```hcl
variable "pm_node" {
  description = "Nom du nœud Proxmox"
  type        = string
  default     = "proxmox"
}

variable "pm_image_template_id" {
  description = "ID du template d'image à utiliser"
  type        = string
  default     = "100"
}

variable "vms" {
  description = "Configuration des machines virtuelles"
  type = map(object({
    vmid     = number
    name     = string
    cores    = number
    memory   = number
    disk_size = string
    ip_address = string
  }))

  default = {
    "debian-1" = {
      vmid       = 101
      name       = "debian-bastion"
      cores      = 2
      memory     = 2048
      disk_size  = "30G"
      ip_address = "192.168.125.10"
    }
    "debian-2" = {
      vmid       = 102
      name       = "debian-dhcp"
      cores      = 1
      memory     = 1024
      disk_size  = "20G"
      ip_address = "192.168.125.11"
    }
  }
}
```

### **3. Définition des ressources - `main.tf`**

```hcl
# Créer une machine virtuelle basée sur un template
resource "proxmox_vm_qemu" "vm" {
  for_each = var.vms

  name        = each.value.name
  vmid        = each.value.vmid
  node        = var.pm_node
  clone       = "debian-template"  # Nom du template à cloner

  cores       = each.value.cores
  memory      = each.value.memory

  # Configuration du disque
  disk {
    type    = "scsi"
    storage = "local-lvm"
    size    = each.value.disk_size
  }

  # Configuration réseau
  network {
    model  = "virtio"
    bridge = "vmbr0"
  }

  # Configuration du cloud-init (si supporté par le template)
  ipconfig0 = "ip=${each.value.ip_address}/24,gw=192.168.125.1"

  # Options de démarrage
  boot = "order=scsi0"

  # Paramètres avancés
  sockets         = 1
  cpu             = "host"
  numa            = false

  # Lifecycle
  lifecycle {
    ignore_changes = [network]
  }
}
```

### **4. Définition des outputs - `outputs.tf`**

```hcl
output "vm_ids" {
  description = "IDs des machines créées"
  value = {
    for name, vm in proxmox_vm_qemu.vm : name => vm.vmid
  }
}

output "vm_ips" {
  description = "Adresses IP des machines"
  value = {
    for name, vm in proxmox_vm_qemu.vm : name => vm.ipconfig0
  }
}

output "vm_names" {
  description = "Noms des machines"
  value = {
    for name, vm in proxmox_vm_qemu.vm : name => vm.name
  }
}
```

### **5. Créer un token API Proxmox**

Sur Proxmox, créer un utilisateur et un token API :

```bash
# Se connecter en SSH à Proxmox
ssh root@proxmox.lab.local

# Créer l'utilisateur
pveum user add terraform@pam

# Créer le token
pveum user token add terraform@pam terraform --privsep 0

# Accorder les permissions (remplacer le token générée)
pveum acl modify / --user terraform@pam --role Administrator
```

Récupérer le token et l'ajouter dans `provider.tf`.

## **Utilisation**

### **Initialiser le projet Terraform**

```bash
terraform init
```

Cette commande télécharge les plugins Proxmox nécessaires.

### **Valider la configuration**

```bash
terraform validate
```

### **Prévisualiser les changements**

```bash
terraform plan
```

Cette commande montre ce que Terraform va créer/modifier/détruire.

### **Appliquer la configuration**

```bash
terraform apply
```

Terraform crée les ressources définies.

### **Détruire l'infrastructure**

```bash
terraform destroy
```

ATTENTION : Cette commande supprime toutes les ressources créées par Terraform.

## **Workflow complet avec le projet**

### **Structure du projet recommandée**

```
terraform/
├── main.tf
├── provider.tf
├── variables.tf
├── outputs.tf
├── terraform.tfvars
├── templates/
│   └── inventory.yml.tpl
└── .gitignore
```

### **Intégration avec Ansible**

Générer un inventaire Ansible à partir de Terraform :

**Template - `templates/inventory.yml.tpl`** :

```yaml
all:
  children:
    bastion:
      hosts:
%{ for name, vm in vms ~}
%{ if strcontains(name, "bastion") ~}
        ${vm.name}:
          ansible_host: ${vm.ip_address}
%{ endif ~}
%{ endfor ~}
```

**Output Terraform** :

```hcl
locals {
  vms_list = {
    for name, vm in proxmox_vm_qemu.vm : name => {
      name       = vm.name
      ip_address = vm.ipconfig0
    }
  }
}

resource "local_file" "inventory" {
  content = templatefile("${path.module}/templates/inventory.yml.tpl", {
    vms = local.vms_list
  })
  filename = "${path.module}/../ansible/inventory.yml"
}
```

### **Workflow complet**

1. **Définir l'infrastructure dans Terraform**

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

2. **Générer l'inventaire Ansible**

L'inventaire est généré automatiquement par Terraform.

3. **Configurer les machines avec Ansible**

```bash
cd ansible
ansible-playbook -i inventory.yml main-playbook.yml
```

## **Bonnes pratiques**

### **Gestion du state**

Le fichier `terraform.tfstate` contient l'état de l'infrastructure. Il doit être :

- **Gardé secret** (ne pas le commit sur Git)
- **Sauvegardé régulièrement**
- **Partagé** entre les membres de l'équipe (utiliser un backend distant)

**Exemple - Backend distant (S3/Minio)** :

```hcl
terraform {
  backend "s3" {
    bucket = "terraform-state"
    key    = "lab/terraform.tfstate"
    region = "eu-west-1"
  }
}
```

### **Variables sensibles**

Utiliser `terraform.tfvars` pour les variables sensibles (mots de passe, tokens) :

```hcl
# terraform.tfvars
pm_api_token_secret = "your-secret-token-here"
```

Ne pas committer ce fichier sur Git.

### **Versioning**

Garder le code Terraform sous contrôle de version :

```bash
git init
git add *.tf
git commit -m "Initial infrastructure configuration"
```

**Fichier `.gitignore`** :

```
terraform.tfstate*
terraform.tfvars
.terraform/
.terraform.lock.hcl
*.log
```

## **Troubleshooting**

### **Problème : Authentification refusée**

Vérifier que le token API est valide et qu'il a les permissions nécessaires.

### **Problème : VM ne crée pas**

Vérifier que le template Proxmox existe et que son ID est correct.

Vérifier les logs : `terraform show`

### **Problème : Changements inattendus**

Utiliser `terraform plan` avant chaque `terraform apply` pour vérifier les changements.

## **Ressources supplémentaires**

- [Documentation Terraform](https://www.terraform.io/docs)
- [Provider Proxmox Telmate](https://registry.terraform.io/providers/Telmate/proxmox/latest)
- [Exemples Terraform Proxmox](https://github.com/Telmate/terraform-provider-proxmox)
