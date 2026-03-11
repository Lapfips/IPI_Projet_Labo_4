# Almalinux

## Présentation
Almalinux est un OS basé sur Linux developpé par Red Hat, il fait partie de RHEL: Red Hat Enterprise Linux
 
## Objectif d'utilisation

L'objectif est simplement d'avoir un OS léger pour héberger les services du projet. L'avantage d'Almalinux c'est que chaque grosse mise a jour est maintenue longtemps et on diminue le risque d'obsolescence de vieilles machines
En outre, avoir un système compatible a la fois sur des distribution Debian et Red Hat permet une plus grande solidité d'infrastructure.

## Ressources nécéssaires
System requirements:

    Disk space: 10GB minimum, 20GB recommended
    Minimum 1.5 GB RAM

## Installation

Il existe 3 version de l'ISO:
- boot: qui va faire une install minimale et télécharger les paquets sur internet
- minimal: une installation fonctionnelle en l'état mais avec juste les paquets nécessaires minimum inclus pour une installation hors ligne
- dvd: une installation complete, hors ligne mais avec une iso plus lourde

L'iso minimale est un bon choix, il faudra de toute façon configurer les miroirs

Pour notre projet, il suffit de charger l'iso dans proxmox et de suivre les étapes d'installation

## Configuration

Important: avoir accès a internet et installer les miroirs

Chaque machine, peu importe l'OS doit avoir un utilisateur dédié a Ansible qui doit être identique d'une machine a l'autre.
Par défaut dans la doc il s'appellera Ansible_User. Cet utilisateur doit disposer des droits d'admin car l'application des playbooks ansible utilisera les droits de cet utilisateur.


Adapter les ressources requises en fonction de la technologie qui tournera dessus.
S'assurer que ssh est fonctionnel (systemctl start sshd, systemctl enable sshd)
La clé publique du serveur ansible devra être insérée (cf doc ansible)


