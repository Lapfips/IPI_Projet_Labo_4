# **Ansible**

## **Présentation**

**Ansible** est un outil d'automatisation **`peer to peer`** qui utilise le protocole **`ssh`** pour se connecter aux machines afin d'effectuer des actions d'installation, de configuration ou de gestion des services. Les scripts sont écrits au format **`YAML`** pour permettre une meilleure lisibilité et écriture par l'humain, avec un système de **playbooks** composés de **tâches** elles-mêmes composées de **modules** officiels ou communautaires et d'attributs permettant la customisation.

## **Objectif d'utilisation**

Dans le projet, **Ansible** a un rôle clé dans le déploiement automatisé en s'occupant de l'installation et de la configuration de toutes les machines et services déployés.

## **Ressources nécessaires**

**Ansible** peut être installé sur divers systèmes d'exploitation, il est basé sur **`Python`** et ne nécessite que son installation et la création d'une paire de clés **`ssh`** pour communiquer avec les autres hôtes.

## **Installation**

Les étapes d'installation dépendent du système d'exploitation.

### **Debian**

Avant d'installer le paquet **Ansible**, il faut mettre à jour les miroirs et paquets.

```
apt update
apt upgrade -y
```

Il suffit maintenant d'installer **Ansible** et ses dépendances.

```
apt install Ansible
```

### **RedHat**

Avant d'installer le paquet **Ansible**, il faut mettre à jour les miroirs et paquets.

```
dnf update
dnf upgrade -y
```

Il suffit maintenant d'installer **Ansible** et ses dépendances.

```
dnf install Ansible
```

## **Configuration**

Après cela, on peut créer la clé **`ssh`** utilisée par **Ansible** si ce n'est pas déjà fait.

```
ssh-keygen -t ed25519 -f ~/.ssh/Ansible_id_ed25519 -C "Ansible automation ssh key"
```

Enfin, il suffit de faire reconnaître cette clé par les machines configurées par **Ansible**.

```
# Template
ssh-copy-id -i ~/.ssh/Ansible_id_ed25519.pub -p PORT ANSIBLE_USER@NOM_DE_LA_MACHINE

# Exemple
ssh-copy-id -i ~/.ssh/Ansible_id_ed25519.pub -p 22 ansible@host
```

## **Utilisation**

Il est maintenant possible d'utiliser **Ansible** avec la commande **`ansible-playbook`** pour exécuter des playbooks avec des rôles et variables.

Le projet **Ansible** a souvent cette structure :

```
inventory1                # Fichier d'inventaire listant les machines
inventory2

group_vars/
   group1.yml             # Groupe de variables pour les appliquées de manière groupé
   group2.yml
host_vars/
   hostname1.yml          # Fichier de variables pour les appliquées à un hôte du même nom
   hostname2.yml

playbook.yml              # Fichier principale qui défini un suite d'opérations à réaliser
roles/
    common/               # Hierarchie d'un rôle
        tasks/            #
            main.yml      # Tâches qui définie les étapes à suivre pour installer
        handlers/         #
            main.yml      # Tâches appellée pour les actions spécifique si nécéssaires
        templates/        # Fichiers de templates pour les configurations
            test.conf.j2  #
        files/            #
            exemple.txt   # Fichier à copier sur l'hôte sans le customiser
        vars/             #
            main.yml      # Variables associées au rôle
        defaults/         #
            main.yml      # Vairbales par défaut du rôle
```
