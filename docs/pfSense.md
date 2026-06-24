# **pfSense**

## **Présentation**

**pfSense** est une distribution firewall/routeur open source basée sur **FreeBSD**. C'est une solution de sécurité réseau complète qui peut remplacer un firewall matériel cher, offrant des fonctionnalités avancées telles que :

- Firewall stateful
- Routage avancé
- VPN (OpenVPN, IPSec)
- Loadbalancing
- Proxy et cache
- Haute disponibilité (CARP)

## **Objectif d'utilisation**

Dans ce projet, pfSense peut être utilisé pour :

- **Pare-feu principal** : Protéger l'infrastructure du laboratoire
- **Routeur** : Gérer le routage entre différents segments réseau
- **DHCP** : Distribution automatique d'adresses IP aux clients
- **DNS** : Service DNS pour résolution de noms
- **VPN** : Accès sécurisé à distance au réseau du labo
- **Monitoring réseau** : Surveillance du trafic et des connexions

## **Ressources nécessaires**

| Ressource         | Minimum             | Recommandé           |
| ----------------- | ------------------- | -------------------- |
| CPU               | 1 vCPU              | 2 vCPU               |
| RAM               | 512 MB              | 2 GB                 |
| Disque            | 8 GB                | 20 GB                |
| Interfaces réseau | 2                   | 3+                   |
| OS                | FreeBSD 13+         | FreeBSD 13+          |
| Console           | Accès serial ou VNC | Accès VNC ou console |

Avant de commencer :

- Image ISO pfSense téléchargée
- Hyperviseur Proxmox fonctionnel
- Accès console pour configuration initiale
- Plan réseau documenté (VLANs, sous-réseaux, etc.)

## **Installation**

### **Téléchargement de l'ISO**

Télécharger pfSense depuis : https://www.pfsense.org/download/

Choisir :

- **Format** : ISO (installation image)
- **Architecture** : AMD64 (x64)
- **Version** : Stable la plus récente

### **Création de la VM dans Proxmox**

1. **Créer une nouvelle VM**
   - **VM ID** : 2001-2999 (plage réservée)
   - **Name** : `pfSense` ou `pfsense-gateway`
   - **ISO** : L'ISO pfSense téléchargé

2. **Configuration système**
   - **CPU** : 2 cores
   - **RAM** : 2 GB
   - **Disque** : 20 GB

3. **Configuration réseau** (important!)
   - **Interface 1** : Bridge `vmbr0` (WAN/Management)
   - **Interface 2** : Bridge `vmbr1` (LAN)
   - (Optionnel) **Interface 3** : Bridge `vmbr2` (DMZ/Services)

4. **Démarrer la VM et installer**

### **Installation pfSense**

Une fois la VM démarrée sur l'ISO :

1. **Écran d'accueil**
   - Appuyer sur `Enter` pour continuer
   - Accepter les termes de la license

2. **Partitionnement**
   - Choisir **UFS** (ou ZFS pour plus avancé)
   - Utiliser toute la capacité disque
   - Auto-partition

3. **Installation**
   - Installer en toute partition
   - Attendre la fin de l'installation

4. **Redémarrage**
   - Retirer l'ISO
   - Laisser démarrer pfSense

### **Configuration initiale (console)**

Au premier démarrage, pfSense affiche un menu de configuration :

```
1. Assign Interfaces
2. Set up WAN interface
3. Set up LAN interface
...
```

#### **1. Assigner les interfaces (Assign Interfaces)**

```
Option: 1
```

Assigner les interfaces réseau :

- **vCPU ID 1** → WAN (exterior/internet)
- **vCPU ID 2** → LAN (réseau interne)

#### **2. Configuration WAN**

```
Option: 2
```

Configuration de l'interface WAN :

- **Type de configuration** : DHCP ou Static IP
- Pour le labo : généralement DHCP ou IP statique

#### **3. Configuration LAN**

```
Option: 3
```

Configuration du réseau interne :

- **IP LAN** : `192.168.125.1` (ou selon votre plan réseau)
- **Subnet mask** : `255.255.255.0` (/24)
- **DHCP server** : Activer (yes)
- **Plage DHCP** : `192.168.125.100 - 192.168.125.200` (exemple)

## **Configuration**

### **Accès à l'interface web**

Une fois la configuration initiale terminée, accéder à l'interface web :

```
https://192.168.125.1
```

Identifiants par défaut :

- **Username** : `admin`
- **Password** : `pfsense`

### **Changer le mot de passe par défaut**

1. **System > User Manager > admin**
2. Cliquer **Edit**
3. Changer le mot de passe
4. Sauvegarder

### **Tableau de bord (Dashboard)**

Le tableau de bord montre :

- État des interfaces
- Statistiques du système
- Logs d'activité
- État du firewall

### **Configuration des interfaces réseau**

Aller dans **Interfaces > Assignments** :

- Vérifier que les interfaces WAN et LAN sont bien assignées
- Ajouter d'autres interfaces si nécessaire (DMZ, VPN, etc.)

### **Configuration du firewall**

**Rules > LAN** pour les règles de firewall entrantes.

**Exemple : Autoriser HTTP et HTTPS vers les services internes** :

1. Aller dans **Firewall > Rules > LAN**
2. Cliquer sur **Add** (+)
3. Configurer :
   - **Action** : Pass
   - **Protocol** : TCP
   - **Destination** : LAN net
   - **Destination Port** : 80, 443
4. Sauvegarder

### **DHCP Server**

Configuration du serveur DHCP pour WAN/LAN :

**Services > DHCP Server > LAN** :

- **Enable DHCP server** : Cocher
- **Range Start** : `192.168.125.100`
- **Range End** : `192.168.125.200`
- **DNS servers** : `8.8.8.8, 8.8.4.4` (Google DNS)
- **Default gateway** : Automatique

Sauvegarder et appliquer.

### **DNS Resolver (Unbound)**

Configurer le DNS resolver local :

**Services > DNS Resolver** :

- **Enable DNS Resolver** : Cocher
- **Listen Port** : `53`
- **Outgoing Network Interface** : WAN
- **DHCP Registration** : Cocher pour enregistrer les clients DHCP

### **Gestion du trafic (Traffic Shaping)**

Pour prioriser certains services :

**Firewall > Traffic Shaper > Queues** :

- Créer des files d'attente pour les services critiques
- Limiter la bande passante par service

### **VPN (OpenVPN)**

Configuration d'un VPN pour accès à distance :

#### **Setup OpenVPN Server**

**VPN > OpenVPN > Wizards** :

1. Cliquer sur **OpenVPN Server Wizard**
2. Configurer :
   - **Description** : `Remote Access VPN`
   - **Authentication** : Local User Access
   - **Cipher** : AES-256-GCM
   - **DH Parameters** : 2048
3. Créer les certificats
4. Finaliser

#### **Exporter les configurations VPN**

Les clients VPN peuvent télécharger les fichiers de configuration depuis :

**VPN > OpenVPN > Client Export**

### **Haute disponibilité (Failover)**

Pour un environnement de production, configurer la haute disponibilité avec CARP :

**System > High Availability** :

- Configurer les adresses CARP
- Setup de synchronisation entre 2 firewalls pfSense

### **Logs et monitoring**

Consulter les logs :

**System > Logs > Firewall** : Tous les logs de firewall

**Status > System Logs > General** : Logs système généraux

## **Sauvegardes**

Sauvegarder la configuration pfSense :

**Diagnostics > Backup & Restore** :

- **Backup Configuration** : Sauvegarder la config actuelle
- **Restore Configuration** : Restaurer une config précédente

Recommandation : Faire une sauvegarde après chaque changement important.

## **Intégration avec le réseau du labo**

### **Segmentation du réseau**

Créer plusieurs VLANs pour segmenter l'infrastructure :

- **VLAN 1 (Management)** : Proxmox, Bastion
- **VLAN 2 (Services)** : Zabbix, GLPI, Nextcloud
- **VLAN 3 (Database)** : PostgreSQL
- **VLAN 4 (User)** : Clients/postes de travail

### **Routage inter-VLAN**

Configurer le routage entre les VLANs sur pfSense.

### **NAT (Network Address Translation)**

Configurer le NAT pour :

- Port forwarding vers les services
- Masquerade pour les clients internes

**Firewall > NAT > Port Forward** :

Exemple : Exposer Guacamole sur le port 8080 :

```
Source: WAN
Destination: 192.168.125.10:8080
Target: 192.168.125.10:8080
```

## **Troubleshooting**

### **Problème : Pas d'accès internet**

- Vérifier la configuration WAN
- Vérifier les règles de firewall
- Vérifier les routes (System > Routing > Gateways)

### **Problème : DHCP ne fonctionne pas**

- Vérifier que le serveur DHCP est activé
- Vérifier la plage DHCP
- Redémarrer le service DHCP (Services > DHCP Server)

### **Problème : VPN ne se connecte pas**

- Vérifier que le service OpenVPN est en cours d'exécution
- Vérifier les certificats
- Consulter les logs OpenVPN

### **Problème : Performance faible**

- Augmenter les ressources CPU/RAM si nécessaire
- Vérifier l'utilisation système (Status > Dashboard)
- Optimiser les règles de firewall

## **Documentation additionnelle**

- [Documentation officielle pfSense](https://docs.netgate.com/pfsense/)
- [Forum pfSense](https://forum.netgate.com/)
- [Wiki pfSense Community](https://wiki.netgate.com/)

## **Maintenance régulière**

1. **Mises à jour** : **System > Update** (vérifier régulièrement)
2. **Sauvegardes** : Effectuer hebdomadairement
3. **Logs** : Archiver et nettoyer les anciens logs
4. **Certificats** : Renouveler avant expiration
5. **Performance** : Monitorer l'utilisation des ressources
