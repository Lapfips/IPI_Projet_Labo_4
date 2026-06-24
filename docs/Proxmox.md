# **`Proxmox`**

## **Présentation**

**`Proxmox Virtual Environment`** (Proxmox VE) est une plateforme de virtualisation open source basée sur **`KVM`** (Kernel-Based Virtual Machine) et **`LXC`** (Linux Containers). Elle combine la virtualisation de machines complètes avec la conteneurisation légère pour gérer efficacement les ressources serveur.

Proxmox offre une interface web d'administration complète, permettant de gérer les machines virtuelles (VM), les conteneurs, le stockage, le réseau, et les sauvegardes depuis un tableau de bord unique.

## **Objectif d'utilisation**

Dans ce projet, Proxmox est utilisé comme :

- **Hyperviseur centralisé** : Héberger toutes les machines virtuelles du laboratoire
- **Plateforme de test** : Créer rapidement des VM pour expérimenter différentes configurations
- **Infrastructure de démonstration** : Montrer une infrastructure IT complète et professionnelle
- **Base pour automatisation** : Intégration avec Terraform et Ansible pour le déploiement automatisé

## **Ressources nécessaires**

### **Matériel serveur**

| Ressource  | Minimum                                      | Recommandé                   |
| ---------- | -------------------------------------------- | ---------------------------- |
| CPU        | 4 cores                                      | 8 cores ou plus              |
| RAM        | 8 GB                                         | 32 GB ou plus                |
| Disque     | 100 GB SSD                                   | 500 GB SSD ou RAID           |
| Réseau     | 1 Gbps                                       | 10 Gbps (optionnel)          |
| Processeur | Support de la virtualisation (VT-x ou AMD-V) | Support de la virtualisation |

### **Logiciel**

- Système d'exploitation : **Debian 11 ou 12**
- Accès root ou administrateur
- Connexion internet pour les mise à jour

### **Avant de commencer**

- Serveur physique ou machine virtuelle de puissance suffisante
- Image ISO Proxmox téléchargée
- Accès console ou à travers un gestionnaire de virtualisation

## **Installation**

### **Téléchargement de l'ISO Proxmox**

Télécharger l'image ISO depuis le site officiel :

```
https://www.proxmox.com/en/proxmox-ve/
```

Choisir la version stable la plus récente (actuellement Proxmox VE 8.x).

### **Préparation du support d'installation**

#### **Sur Windows/Mac**

Utiliser un outil comme **Rufus** (Windows) ou **Etcher** (Mac) pour créer une clé USB bootable avec l'ISO Proxmox.

#### **Sur Linux**

```bash
# Identifier le périphérique USB
lsblk

# Créer la clé bootable (adapter sdX selon le résultat)
sudo dd if=proxmox-ve_*.iso of=/dev/sdX bs=4M status=progress
sync
```

### **Installation sur le serveur**

1. **Booter sur la clé USB ou l'ISO**

2. **Écran de bienvenue**
   - Cliquer sur **Install Proxmox VE**

3. **Accord de licence**
   - Lire et accepter les termes de la license

4. **Sélection du disque**
   - Choisir le disque cible (ATTENTION : données existantes seront supprimées)
   - Configurer le partitionnement (laisser par défaut généralement)

5. **Configuration du pays et fuseau horaire**
   - Sélectionner le pays et le fuseau horaire

6. **Configuration du mot de passe et email**
   - Entrer un mot de passe root fort
   - Entrer une adresse email pour les notifications

7. **Configuration du réseau**
   - Configurer le hostname (ex: `proxmox.lab.local`)
   - Configurer l'adresse IP et la passerelle
   - Configurer les serveurs DNS

8. **Résumé et installation**
   - Vérifier tous les paramètres
   - Cliquer sur **Install** et attendre la fin de l'installation

9. **Redémarrage**
   - Retirer le support d'installation
   - Le système redémarre automatiquement

## **Configuration initiale**

### **Accès à l'interface web**

Une fois l'installation terminée, accéder à Proxmox via :

```
https://IP_PROXMOX:8006
```

Exemple : `https://192.168.125.1:8006`

### **Connexion initiale**

- **Utilisateur** : `root@pam`
- **Mot de passe** : Celui défini lors de l'installation

### **Configuration de base**

#### **1. Mise à jour du système**

Une fois logué, aller dans :

**Nœud** > **Updates** > **Refresh** puis **Upgrade**

Ou via terminal SSH :

```bash
apt update
apt upgrade -y
```

#### **2. Configuration du stockage**

Aller dans **Datacenter** > **Storage** pour ajouter du stockage (disques durs, SSD, NAS, etc.).

**Types de stockage courants** :

- **Local** : Stockage local sur le serveur Proxmox
- **LVM** : Logical Volume Manager pour gérer les disques
- **NFS** : Stockage réseau (partage NAS)

#### **3. Création d'un réseau virtuel de gestion**

Par défaut, Proxmox utilise le pont réseau `vmbr0` pour la gestion et les VM.

Pour ajouter d'autres réseaux, aller dans **Nœud** > **Network** et ajouter des ponts réseau.

#### **4. Configuration des certificats SSL**

Générer des certificats SSL pour sécuriser les connexions :

```bash
# Générer une clé privée
openssl genrsa -out /tmp/proxmox.key 2048

# Générer un certificat autosigné
openssl req -new -x509 -key /tmp/proxmox.key -out /tmp/proxmox.crt \
    -days 365 -subj "/C=FR/ST=France/L=City/O=Lab/CN=proxmox.lab.local"

# Copier les fichiers vers le bon emplacement
cp /tmp/proxmox.key /etc/pve/nodes/$(hostname)/pve-ssl.key
cp /tmp/proxmox.crt /etc/pve/nodes/$(hostname)/pve-ssl.pem
```

### **Création d'une première machine virtuelle**

1. Cliquer sur **Create VM** (en haut à droite)

2. **Onglet General**
   - **Node** : Proxmox (par défaut)
   - **VM ID** : `100` (au moins)
   - **Name** : Nom descriptif (ex: `debian-test`)

3. **Onglet OS**
   - **ISO Image** : Sélectionner ou uploader une ISO Debian
   - Si pas d'ISO, l'uploader d'abord dans **Datacenter** > **Content**

4. **Onglet System**
   - Laisser par défaut généralement

5. **Onglet Disks**
   - **Storage** : Sélectionner le stockage cible
   - **Disk size** : Adapter selon les besoins (20-50 GB)

6. **Onglet CPU**
   - **Cores** : Nombre de CPU virtuels à allouer

7. **Onglet Memory**
   - **Memory** : RAM en MB (ex: 2048 pour 2GB)

8. **Onglet Network**
   - **Bridge** : `vmbr0` par défaut
   - Laisser les autres paramètres par défaut

9. **Review**
   - Vérifier les paramètres
   - Cliquer sur **Finish** pour créer la VM

10. **Démarrage de la VM**
    - Sélectionner la VM dans la liste
    - Cliquer sur **Start**
    - Utiliser la console pour installer le système d'exploitation

## **Configuration avancée**

### **Snapshots et sauvegarde**

Pour chaque VM importante, créer des snapshots réguliers :

1. Sélectionner la VM
2. Aller dans **Snapshots**
3. Cliquer sur **Take Snapshot**
4. Donner un nom et une description

Pour la sauvegarde complète, utiliser **Backup** :

1. Aller dans **Datacenter** > **Backup**
2. Configurer les paramètres de sauvegarde
3. Planifier des sauvegardes régulières

### **Migration de VM**

Pour migrer une VM vers un autre nœud (utile en cluster) :

1. Cliquer droit sur la VM
2. Sélectionner **Migrate**
3. Choisir le nœud cible

### **Clustering Proxmox**

Pour un environnement de production, configurer un cluster Proxmox :

```bash
# Sur le premier nœud
pvecm create CLUSTER_NAME

# Sur les autres nœuds
pvecm add FIRST_NODE_IP
```

## **Intégration avec Terraform**

Proxmox peut être automatisé via Terraform pour créer et configurer des VM programmatiquement.

Voir la documentation **Terraform** pour les détails.

## **Intégration avec Ansible**

Les VM créées par Proxmox peuvent être configurées automatiquement par Ansible.

Voir la documentation **Ansible** pour les détails.

## **Maintenance et monitoring**

### **Logs de Proxmox**

Consulter les logs pour diagnostiquer les problèmes :

```bash
# Logs système
journalctl -u pvemanager -f

# Logs de la GUI
tail -f /var/log/pveproxy.log
```

### **Utilisation des ressources**

Aller dans **Datacenter** > **Summary** pour voir l'utilisation CPU, RAM et disque du serveur Proxmox.

### **Mise à jour Proxmox**

Mettre à jour Proxmox régulièrement pour bénéficier des correctifs de sécurité :

```bash
apt update
apt upgrade -y
```

Pour les mises à jour majeures, consulter les notes de version sur le site Proxmox.

## **Troubleshooting**

### **Problème : VM ne démarre pas**

- Vérifier que le disque a assez d'espace
- Vérifier les logs de la VM dans la console
- Vérifier que l'ISO de démarrage est accessible

### **Problème : Pas d'accès réseau**

- Vérifier que le pont réseau `vmbr0` est configuré correctement
- Vérifier les paramètres réseau de la VM
- Tester la connectivité depuis la VM

### **Problème : Accès à l'interface web impossible**

- Vérifier que le service pveproxy est en cours d'exécution : `systemctl status pveproxy`
- Vérifier le pare-feu : `sudo ufw allow 8006`
- Redémarrer Proxmox si nécessaire : `reboot`
