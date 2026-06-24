# **`Confluence`**

## **Présentation**

**`Confluence`** est une plateforme collaborative de gestion de documentation et de wikis d'entreprise développée par Atlassian. Elle permet aux équipes de créer, organiser et partager de la documentation, des procédures, des plans de projet et des bases de connaissances centralisées.

Confluence s'intègre étroitement avec **Jira** (gestion de projets) pour une collaboration complète entre documentation et gestion de tâches.

## **Objectif d'utilisation**

Dans ce projet, Confluence est utilisé pour :

- **Documentation centralisée** : Guide d'utilisation, procédures d'administration, FAQ
- **Base de connaissances** : Dépôt de connaissance pour le laboratoire
- **Plans d'architecture** : Documenter l'infrastructure déployée
- **Runbooks** : Procédures d'exploitation et de dépannage
- **Collaboration** : Permettre aux équipes de collaborer sur la documentation

## **Ressources nécessaires**

| Ressource              | Minimum        | Recommandé                       |
| ---------------------- | -------------- | -------------------------------- |
| CPU                    | 2 vCPU         | 4 vCPU                           |
| RAM                    | 2 GB           | 4-8 GB                           |
| Disque                 | 20 GB          | 50 GB                            |
| Système d'exploitation | Debian 12      | Debian 12 ou AlmaLinux           |
| Java Runtime           | OpenJDK 11+    | OpenJDK 17+                      |
| Base de données        | PostgreSQL 12+ | PostgreSQL 12+ ou MySQL 8+       |
| Navigateur web         | Moderne        | Chrome, Firefox, Safari (récent) |

Avant de commencer :

- Machine virtuelle dédiée
- Java Runtime installé
- PostgreSQL ou MySQL installé et fonctionnel
- Apache web server (optionnel, pour proxy inverse)
- Accès root ou droits sudo
- Connexion internet

## **Installation**

### **Prérequis**

Installer Java et les dépendances :

**Debian** :

```bash
apt update
apt install openjdk-17-jdk openjdk-17-jre-headless wget -y
```

**AlmaLinux** :

```bash
dnf install java-17-openjdk java-17-openjdk-devel wget -y
```

Vérifier l'installation Java :

```bash
java -version
```

### **Création de l'utilisateur Confluence**

Créer un utilisateur système pour Confluence :

```bash
sudo useradd -m -d /home/confluence -s /usr/sbin/nologin confluence
```

### **Création de la base de données PostgreSQL**

Créer l'utilisateur et la base de données :

```bash
sudo -u postgres createuser --pwprompt confluence
sudo -u postgres createdb -O confluence confluence
```

### **Téléchargement de Confluence**

Télécharger Confluence depuis le site Atlassian :

```bash
cd /tmp
wget https://www.atlassian.com/software/confluence/downloads/binary/atlassian-confluence-7.20.0-x64.bin
```

Adapter la version selon celle disponible.

### **Installation de Confluence**

Rendre le fichier exécutable et lancer l'installation :

```bash
chmod +x atlassian-confluence-7.20.0-x64.bin
sudo ./atlassian-confluence-7.20.0-x64.bin
```

Suivre l'assistant d'installation :

1. **Chemin d'installation** : Par défaut `/opt/atlassian/confluence`
2. **Répertoire de données** : Par défaut `/var/atlassian/application-data/confluence`
3. **Port HTTP** : Par défaut `8090`
4. **Démarrage du service** : Cocher pour démarrer Confluence automatiquement

## **Configuration**

### **Accès initial à Confluence**

Une fois l'installation terminée, accéder à Confluence via :

```
http://votre-serveur:8090
```

### **Assistance à la configuration**

L'assistant de configuration vous guidera à travers les étapes suivantes :

#### **1. Licence Confluence**

- Pour l'installation d'évaluation, ne remplir rien (version d'essai 30 jours)
- Pour une license gratuite (académique/petites équipes), entrer la clé
- Pour une license commerciale, entrer la clé et l'organisation

#### **2. Type d'installation**

- Choisir **Standalone** pour un déploiement simple
- Ou **Cluster** pour un environnement haute disponibilité

#### **3. Configuration de la base de données**

- Sélectionner **PostgreSQL**
- Entrer les détails de connexion :
  - **Hostname** : `localhost`
  - **Port** : `5432`
  - **Database** : `confluence`
  - **Username** : `confluence`
  - **Password** : (mot de passe défini)

#### **4. Utilisateur administrateur**

- Entrer le nom d'utilisateur administrateur initial
- Entrer le mot de passe
- Entrer l'email

### **Configuration de base**

Une fois logué, effectuer la configuration basique :

#### **1. Configuration générale**

Aller dans **Settings** > **General Configuration** :

- **Site Name** : Donner un nom au wiki (ex: "Lab Documentation")
- **Site URL** : Vérifier que l'URL est correcte
- **Language** : Choisir français si désiré

#### **2. Création d'espaces**

Les espaces sont les conteneurs de documentation dans Confluence.

Créer un nouvel espace :

1. Cliquer sur **Spaces** > **Create Space**
2. Choisir **Blank Space** (vierge)
3. Entrer un **Space Name** (ex: "Administration")
4. Entrer une **Space Key** (ex: "ADMIN")

#### **3. Création de pages**

Pour chaque espace, créer des pages de documentation :

1. Aller dans l'espace
2. Cliquer sur **Create** > **Page**
3. Écrire la documentation avec l'éditeur WYSIWYG

### **Configuration Apache en tant que proxy inverse**

Pour accéder à Confluence via un port standard (80/443), configurer Apache :

```bash
nano /etc/apache2/sites-available/confluence.conf
```

**Contenu** :

```apache
<VirtualHost *:80>
    ServerName confluence.lab.local
    ServerAdmin admin@lab.local

    ProxyPreserveHost On
    ProxyPass / http://localhost:8090/
    ProxyPassReverse / http://localhost:8090/

    RequestHeader set X-Forwarded-Proto http
    RequestHeader set X-Forwarded-Host confluence.lab.local
</VirtualHost>

<VirtualHost *:443>
    ServerName confluence.lab.local
    ServerAdmin admin@lab.local

    SSLEngine on
    SSLCertificateFile /etc/ssl/certs/confluence.crt
    SSLCertificateKeyFile /etc/ssl/private/confluence.key

    ProxyPreserveHost On
    ProxyPass / http://localhost:8090/
    ProxyPassReverse / http://localhost:8090/

    RequestHeader set X-Forwarded-Proto https
    RequestHeader set X-Forwarded-Host confluence.lab.local
</VirtualHost>
```

Activer la configuration :

```bash
a2ensite confluence.conf
a2enmod proxy
a2enmod proxy_http
a2enmod ssl
a2enmod headers
systemctl reload apache2
```

### **Intégration avec Jira**

Pour lier Confluence à Jira, aller dans :

**Settings** > **Jira Integration** :

- Entrer l'URL de Jira
- Configurer l'authentification

### **Gestion des utilisateurs**

#### **Créer des utilisateurs locaux**

1. Aller dans **Settings** > **Users and permissions** > **Users**
2. Cliquer sur **Create user**
3. Entrer les détails

#### **LDAP/AD (Active Directory)**

Pour l'authentification centralisée :

1. Aller dans **Settings** > **User Directories**
2. Ajouter un répertoire **LDAP**
3. Configurer les paramètres LDAP

### **Groupes d'utilisateurs**

Créer des groupes pour gérer les permissions :

1. Aller dans **Settings** > **Groups**
2. Cliquer sur **Create group**
3. Ajouter des utilisateurs au groupe

### **Permissions d'espaces**

Gérer les permissions par espace :

1. Aller dans l'espace
2. Cliquer sur **Space settings** > **Permissions**
3. Attribuer les rôles (View, Edit, Admin)

### **Sauvegarde**

Créer un script de sauvegarde régulière :

```bash
#!/bin/bash
BACKUP_DIR="/backup/confluence"
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p $BACKUP_DIR

# Sauvegarde PostgreSQL
sudo -u postgres pg_dump confluence | gzip > $BACKUP_DIR/confluence_db_$DATE.sql.gz

# Sauvegarde répertoire de données
tar -czf $BACKUP_DIR/confluence_data_$DATE.tar.gz /var/atlassian/application-data/confluence

# Garder les 7 dernières sauvegardes
find $BACKUP_DIR -name "confluence_*" -mtime +7 -delete
```

Planifier la sauvegarde :

```bash
chmod +x /usr/local/bin/confluence_backup.sh
echo "0 4 * * * /usr/local/bin/confluence_backup.sh" | crontab -
```

## **Utilisation**

### **Structure documentaire recommandée**

```
Lab Documentation (Space)
├── Getting Started
│   ├── Présentation du labo
│   ├── Architecture générale
│   └── Accès initial
├── Infrastructure
│   ├── Proxmox
│   ├── Terraform
│   └── Networking
├── Services
│   ├── Zabbix
│   ├── GLPI
│   ├── Guacamole
│   └── Nextcloud
├── Procedures
│   ├── Création VM
│   ├── Déploiement
│   └── Dépannage
└── FAQ
```

### **Templates et macros**

Confluence propose des templates pour standardiser la documentation :

- **Page de procédure**
- **FAQ**
- **Architecture**
- **Contact**

## **Maintenance**

### **Logs Confluence**

Consulter les logs :

```bash
tail -f /var/atlassian/application-data/confluence/logs/catalina.out
```

### **Tâches de maintenance**

1. **Vérifier l'espace disque**

```bash
df -h /var/atlassian/application-data/confluence
```

2. **Archiver les anciennes pages** : Via l'interface d'administration

3. **Optimiser la base de données** : Maintenance PostgreSQL

### **Mise à jour Confluence**

Pour mettre à jour Confluence, télécharger la nouvelle version et suivre le processus d'installation décrit ci-dessus.

## **Troubleshooting**

### **Problème : Confluence ne démarre pas**

Vérifier les logs :

```bash
tail -100 /var/atlassian/application-data/confluence/logs/catalina.out
```

Vérifier que PostgreSQL est accessible et que la base existe.

### **Problème : Base de données pleine**

Augmenter la taille du disque de la base de données ou archiver les anciennes données.

### **Problème : Performance lente**

- Vérifier l'utilisation RAM et CPU
- Optimiser les requêtes PostgreSQL
- Activer le cache Confluence
