# **IPI_Projet_Labo_4**

Projet laboratoire **N°4** de l'**Institut de Poly-Informatique de Blagnac**

## **Collaborateurs**

**B3 ASRBD G1** :

- **Ethan FARGIER**
- **Quentin CAVALLO**
- **Lou LEGRAND**

## **Architecture de fichiers**

L'architecture de fichiers du projet est basée sur le schéma suivant :

```
**ansible/**                # Fichiers utilisés par **Ansible** pour installer et configurer les services
    **group_vars/**
        .../
    **host_vars/**
        .../
    **rôles/**
        .../
    `ansible.cfg`
    `inventory.yml`
    `playbook.yml`
**docs/**                   # Documentations sur les technologies utilisées
    ...
**schemas/**                # Schémas de présentation du projet
    `schema_physique`
    `schema_reseau`
**scripts/**                # Scripts de déploiement des différentes parties du projet
    `ansible-vault.sh`
    `deploy.sh`
    `destroy.sh`
    `full_deploy.sh`
    `integrity.sh`
    `main.sh`
    `setup_proxmox.sh`
    `tests.sh`
**terraform/**              # Fichiers utilisés par **Terraform** pour le provisionnement des machines
    `main.tf`
    `outputs.tf`
    `provider.tf`
    `terraform.tfvars`
    `variable.tf`

# Fichiers
`.gitignore`                # Fichier permettant d'exclure des fichiers de la synchronisation **git**
`README.md`                 # Ce fichier permettant de présenter le projet
```

## **Schéma réseau**

Les schémas sont accessible en SVG ici :

- [Schéma réseau (SVG)](schemas/schema_reseau.svg)
- [Schéma physique (SVG)](schemas/schema_physique.svg)

## TODO

- Docs
  - Apache2
  - Confluence
  - DHCP
  - DNS
  - GLPI
  - Guacamole
  - Jira
  - pfSense
  - Proxmox
  - Terraform
  - Zabbix

- Reviews and tests
  - Ansible
  - Terraform
  - Scripts
