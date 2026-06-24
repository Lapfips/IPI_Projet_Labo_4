# **`DNS`**

## **Présentation**

Le **`DNS`** (**`Domain Name System`**) est un service réseau fondamental qui traduit les noms de domaine lisibles par l'humain (par exemple : `example.com`) en adresses IP numériques (par exemple : `192.168.1.10`) que les ordinateurs utilisent pour communiquer. C'est le système de "répertoire" d'Internet.

## **Objectif d'utilisation**

- Résoudre les noms de domaine en adresses IP pour le réseau interne et permettre la communication entre services
- Fournir un service de résolution de noms pour tous les clients du réseau
- Gérer les zones **`DNS`** du domaine interne
- Permettre la découverte de services via les noms d'hôtes plutôt que les adresses IP

## **Ressources nécessaires**

| Ressource                      | Description                                          |
| ------------------------------ | ---------------------------------------------------- |
| Serveur Debian 12 ou AlmaLinux | Machine dédiée pour le serveur DNS                   |
| 1 interface réseau             | Connectée au réseau interne                          |
| 512 MB RAM                     | Minimum pour le service DNS                          |
| 1 vCPU                         | Suffisant pour un petit réseau                       |
| 2 GB disque                    | Pour les fichiers de configuration et logs           |
| Accès root                     | Nécessaire pour installer et configurer les services |

Avant de commencer :

- Une machine virtuelle fonctionnelle (Debian ou AlmaLinux)
- Accès SSH ou console
- Connexion internet pour télécharger les paquets

## **Installation**

### **Debian**

Mettre à jour le système :

```bash
apt update
apt upgrade -y
```

Installer le serveur DNS **BIND** (Berkeley Internet Name Daemon) et les outils associés :

```bash
apt install bind9 bind9-utils dnsutils -y
```

Vérifier l'installation :

```bash
named -v
```

### **AlmaLinux / Red Hat**

Mettre à jour le système :

```bash
dnf update
dnf upgrade -y
```

Installer BIND :

```bash
dnf install bind bind-utils -y
```

Vérifier l'installation :

```bash
named -v
```

## **Configuration**

### **Structure des fichiers de configuration**

**Debian** : Les fichiers se trouvent dans `/etc/bind/`

**AlmaLinux** : Les fichiers se trouvent dans `/etc/named/` ou `/etc/named.conf`

### **Configuration de base - Fichier principal**

Éditer le fichier principal de configuration :

**Debian** :

```bash
nano /etc/bind/named.conf.local
```

**AlmaLinux** :

```bash
nano /etc/named.conf
```

### **Exemple de configuration pour zone interne**

Ajouter la configuration de la zone :

```bash
zone "lab.local" {
    type master;
    file "/etc/bind/zones/db.lab.local";  # Debian
    # ou
    file "/var/named/zones/db.lab.local"; # AlmaLinux
    allow-transfer { any; };
};

zone "125.168.192.in-addr.arpa" {
    type master;
    file "/etc/bind/zones/db.192.168.125";  # Debian
    # ou
    file "/var/named/zones/db.192.168.125"; # AlmaLinux
};
```

### **Création des fichiers de zone**

Créer le répertoire des zones :

**Debian** :

```bash
mkdir -p /etc/bind/zones
```

**AlmaLinux** :

```bash
mkdir -p /var/named/zones
```

Créer le fichier de zone avant (`db.lab.local`) :

```bash
nano /etc/bind/zones/db.lab.local
```

**Exemple de contenu** :

```dns
$TTL 604800
@ IN SOA ns1.lab.local. admin.lab.local. (
            2024062401  ; Serial
            604800      ; Refresh
            86400       ; Retry
            2419200     ; Expire
            604800 )    ; Minimum TTL
    IN NS ns1.lab.local.

ns1     IN A 192.168.125.2
proxy   IN A 192.168.125.3
dhcp    IN A 192.168.125.4
zabbix  IN A 192.168.125.5
glpi    IN A 192.168.125.6
```

Créer le fichier de zone inverse (`db.192.168.125`) :

```bash
nano /etc/bind/zones/db.192.168.125
```

**Exemple de contenu** :

```dns
$TTL 604800
@ IN SOA ns1.lab.local. admin.lab.local. (
            2024062401  ; Serial
            604800      ; Refresh
            86400       ; Retry
            2419200     ; Expire
            604800 )    ; Minimum TTL
    IN NS ns1.lab.local.

2   IN PTR ns1.lab.local.
3   IN PTR proxy.lab.local.
4   IN PTR dhcp.lab.local.
5   IN PTR zabbix.lab.local.
6   IN PTR glpi.lab.local.
```

### **Configuration des permissions**

**Debian** :

```bash
chown -R bind:bind /etc/bind/zones
chmod 755 /etc/bind/zones
chmod 644 /etc/bind/zones/db.*
```

**AlmaLinux** :

```bash
chown -R named:named /var/named/zones
chmod 755 /var/named/zones
chmod 644 /var/named/zones/db.*
```

### **Configuration des forwarders (optionnel)**

Pour faire suivre les requêtes DNS vers d'autres serveurs DNS (comme ceux du fournisseur), éditer :

```bash
options {
    forwarders {
        8.8.8.8;
        8.8.4.4;
    };
};
```

### **Démarrage du service**

**Debian** :

```bash
systemctl start bind9
systemctl enable bind9
systemctl status bind9
```

**AlmaLinux** :

```bash
systemctl start named
systemctl enable named
systemctl status named
```

### **Vérification de la configuration**

Vérifier la syntaxe :

**Debian** :

```bash
named-checkconf
```

**AlmaLinux** :

```bash
named-checkconf
```

Tester la résolution DNS locale :

```bash
nslookup ns1.lab.local 192.168.125.2
dig zabbix.lab.local @192.168.125.2
```

### **Configuration des clients**

Sur les clients du réseau, configurer le serveur DNS pour qu'il pointe vers le serveur DNS que vous venez de configurer :

**Fichier `/etc/resolv.conf` (temporaire)** :

```bash
nameserver 192.168.125.2
```

**Fichier `/etc/netplan/` (permanent sur Debian)** :

```yaml
network:
  version: 2
  ethernets:
    eth0:
      dhcp4: true
      nameservers:
        addresses: [192.168.125.2]
```

Appliquer la configuration :

```bash
netplan apply
```

### **Logs et monitoring**

Consulter les logs du DNS :

**Debian** :

```bash
journalctl -u bind9 -f
```

**AlmaLinux** :

```bash
journalctl -u named -f
```

## **Troubleshooting**

Vérifier la résolution inverse :

```bash
dig -x 192.168.125.5 @192.168.125.2
```

Vérifier que le port 53 est en écoute :

```bash
netstat -an | grep 53
ss -lun | grep 53
```

Augmenter le niveau de logging si nécessaire :

```bash
echo "logging { channel default_log { file \"/var/log/named/debug.log\"; severity debug; }; category default { default_log; }; };" >> /etc/bind/named.conf.local
```
