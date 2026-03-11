
# **IPI_Projet_Labo_4**


Projet laboratoire **N°4** de l'**Institut de Poly-Informatique de Blagnac**

## **Collaborateurs**


**B3 ASRBD G1** :

* **Ethan FARGIER**
* **Quentin CAVALLO**
* **Lou LEGRAND**

## **Architecture de fichiers**

L'architecture de fichiers du projet est basée sur le schéma suivant :

```
**ansible/**                # Fichiers utilisés par **Ansible** pour installer et configurer les services
    `ansible.cfg`
    `inventory.yml`
    `playbook.yml`
    **group_vars/**
        .../
    **host_vars/**
        .../
    **rôles/**
        .../
**terraform/**              # Fichiers utilisés par **Terraform** pour le provisionnement des machines
    `main.tf`
    `variable.tf`
    `terraform.tfvars`
    `provider.tf`
**scripts/**                # Scripts de déploiement des différentes parties du projet
    `main.sh`
    `proxmox.sh`
    `ansible.sh`
    `terraform.sh`
    `tests.sh`
**docs/**                   # Documentations sur les technologies utilisées
    ...
**schemas/**                # Schémas de présentation du projet
    `schema_reseau`
    `schema_physique`
`.gitignore`              # Fichier permettant d'exclure des fichiers de la synchronisation **git**
`README.md`               # Ce fichier permettant de présenter le projet
```

## **Schéma réseau**
