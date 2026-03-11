# **Debian**

## **Présentation**

Debian est un système d'exploitation et une distribution de logiciels libres. Elle est largement utilisée pour les serveurs, les environnements de développement et les laboratoires

## **Objectif d'utilisation**

Depuis Proxmox, installer une ou des VM tournant sur Debian pour héberger les services mis à disposition pour le labo

## **Ressources nécéssaires**

 Ressource | Minimum | Recommandé
|-----------|---------|------------| 
| CPU | 1 vCPU | 2 vCPU 
| RAM | 512 MB | 2 GB 
| Stockage | 8 GB | 20 GB |
| Réseau | 1 interface | 1 interface |
| OS | Debian minimal | Debian avec paquets supplémentaires |



Avant de commencer vérifier que toutes ces étapes soit fonctionnelles :

- un hyperviseur Proxmox fonctionnel

- une image ISO Debian

- un accès à l’interface web Proxmox

## **Installation**

### **Téléchargement ISO**

Télécharger l'image ISO officielle depuis : https://www.debian.org

Choisir : Debian 12

----

### **Coté Proxmox**

Se connecter depuis un navigateur à l’interface d’administration de proxmox, en général : https://serveur:8006/ (à adapter avec le nom de votre serveur Proxmox)

Une fois que vous avez accès à l'interface graphique de Proxmox il faut uploader l'ISO de Debian dans Proxmox. Pour cela il faut suivre les étapes suivantes :
- Aller à gauche sur le Noeud, puis “local”.
- Dans `ISO Images`, cliquer sur `Upload` > `select file`et choisir l’iso téléchargé
- Puis `Upload` et attendre que l’iso se téléverse.

---

### **Etape création VM**

1. En haut à droite cliquer sur `Create VM`

2. Dans `Général` :
    - `Node` : Laisser celui par défaut, il s’agit du noeud sur laquelle la VM sera déployée.
    - `VM ID` : Il y a une nomenclature à respecter afin d’avoir une visibilité sur les VM’s : 1000 à
    1999 = Linux et 2000 à 2999 = Windows. Comme c’est un Linux et que c’est la première VM : 1001 ou plus grand si ce n'est pas la première
    - `Name` : ici, pour identifier la VM facilement mettre son futur hostname.

3. Dans `OS` : laisser les options par défaut, il suffit juste de choisir l’image ISO à amorcer pour le déploiement
dans la liste déroulante (ici Debian 12)

4. Dans `System` : laisser toutes les options pas de changements nécessaires 

5. Dans `Disks` : Choisir la taille disque suivant les besoins 

6. Dans `CPU` : Choisir le nombre de coeurs à allouer à la VM, cette valeur varie en fonction de la
charge travail du serveur

7. Dans `Memory` : Choisir la capacité selon les besoins également

8. Dans `Network` : laisser les otions par défaut

9. Enfin dans `Confirm` on obtient un récapitulatif si tout vous parait ok cliquer sur `Finish` puis lancer la vm, dans `Console`, puis `Start Now`

---

### **Installtion Debian**

Concernant les étapes d'installation de la machine Debian il n'y a pas de spécificité en particulier. 

Il faut par contre faire une machine **sans interface graphique**

Pour cela il faudra décocher sur l'étape de la séléction des paquets : 

Décocher tout sauf :

- ✔ SSH server
- ✔ standard system utilities

Ne pas sélectionner :

- ✘ Debian desktop environment
- ✘ GNOME
- ✘ KDE
- ✘ XFCE

## **Configuration**

Une fois l'installation finie il vous demandera votre login et password 

### **Etape 1 : Installer et configurer `sudo`**

```bash
su -
adduser <VOTRE UTILISATEUR> sudo
sudo -u <VOTRE UTILISATEUR> echo bonjour
groups nom_utilisateur
sudo apt update
```

---

### **Etape 2 : Mettre à jour le système**

```bash
sudo apt update
sudo apt upgrade -y
```
---

### **Etape 3 : Installer les outils utiles**

```bash
sudo apt install nom_du_paquet
```

---

### **Probleme de mirroirs**

Si vous rencontrez des erreurs lors de la mise à jour système de l'installation des paquets c'est qu'il y a un probème de mirroir. Il faut donc aller les modifier

```bash 
sudo nano /etc/apt/sources.list
```

Commenter les lignes commençant par `deb http://security.debian.org` et `deb-src http://security.debian.org/`

---

### **Etape 4 : Création de l'utilisateur avec les droits nécessaires pour Ansible**

Chaque machine, peu importe l'OS, doit avoir un utilisateur dédié à **Ansible** qui doit être identique d'une machine à l'autre.
Par défaut dans la documentation, il s'appellera **`Ansible_User`**. Cet utilisateur doit disposer des droits d'admin car l'application des playbooks **Ansible** utilisera les droits de cet utilisateur.

```bash
su -
adduser ansible_user
usermod -aG sudo ansible_user
groups ansible_user
```