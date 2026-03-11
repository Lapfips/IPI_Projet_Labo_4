# **AlmaLinux**

## **Présentation**

**AlmaLinux** est un OS basé sur **`Linux`** développé par **Red Hat**. Il fait partie de **`RHEL`** : **Red Hat Enterprise Linux**.

## **Objectif d'utilisation**

L'objectif est simplement d'avoir un OS léger pour héberger les services du projet. L'avantage d'**AlmaLinux** est que chaque grosse mise à jour est maintenue longtemps, ce qui diminue le risque d'obsolescence des vieilles machines.
En outre, avoir un système compatible à la fois sur des distributions **Debian** et **Red Hat** permet une plus grande solidité d'infrastructure.

## **Ressources nécessaires**

**System requirements** :

    **Disk space** : `10GB` minimum, `20GB` recommandé
    **RAM** : minimum `1.5GB`

## **Installation**

Il existe 3 versions de l'ISO :

- **boot** : fait une installation minimale et télécharge les paquets sur internet
- **minimal** : installation fonctionnelle en l'état, avec juste les paquets nécessaires minimum inclus pour une installation hors ligne
- **dvd** : installation complète, hors ligne mais avec une ISO plus lourde

L'ISO **minimal** est un bon choix, il faudra de toute façon configurer les miroirs.

Pour notre projet, il suffit de charger l'ISO dans **Proxmox** et de suivre les étapes d'installation.

## **Configuration**

**Important** : avoir accès à internet et installer les miroirs.

Chaque machine, peu importe l'OS, doit avoir un utilisateur dédié à **Ansible** qui doit être identique d'une machine à l'autre.
Par défaut dans la documentation, il s'appellera **`Ansible_User`**. Cet utilisateur doit disposer des droits d'admin car l'application des playbooks **Ansible** utilisera les droits de cet utilisateur.

Adapter les ressources requises en fonction de la technologie qui tournera dessus.
S'assurer que **`ssh`** est fonctionnel (`systemctl start sshd`, `systemctl enable sshd`).
La clé publique du serveur **Ansible** devra être insérée (cf doc **Ansible**).
