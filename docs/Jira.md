# **`Jira`**

## **Présentation**

**`Jira`** est une plateforme de gestion de projets et de suivi de tickets d'erreurs (issue tracking) développée par Atlassian. Elle est largement utilisée dans les équipes logicielles pour gérer les tâches, les bugs, les demandes de fonctionnalités et le suivi global du projet.

Jira propose des méthodologies de gestion de projet comme **Scrum** et **Kanban**, et s'intègre avec de nombreux outils de développement (Git, Jenkins, Confluence, etc.).

## **Objectif d'utilisation**

Dans ce projet, Jira est utilisé pour :

- **Gestion de projets** : Suivi des tâches du laboratoire et des projets IT
- **Suivi des bugs** : Rapport et suivi des problèmes rencontrés
- **Planification** : Organiser les sprints et les jalons du projet
- **Documentation de travail** : Garder une trace de toutes les tâches effectuées
- **Collaboration** : Coordination entre membres de l'équipe
- **Intégration CI/CD** : Liaison avec les pipelines d'automatisation

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
- PostgreSQL ou MySQL installé
- Apache web server (optionnel)
- Accès root ou droits sudo
- Connexion internet

## **Installation**

### **Prérequis**

Installer Java :

**Debian** :

```bash
apt update
apt install openjdk-17-jdk openjdk-17-jre-headless wget -y
```

**AlmaLinux** :

```bash
dnf install java-17-openjdk java-17-openjdk-devel wget -y
```

Vérifier Java :

```bash
java -version
```

### **Création de l'utilisateur Jira**

Créer un utilisateur système :

```bash
sudo useradd -m -d /home/jira -s /usr/sbin/nologin jira
```

### **Création de la base de données PostgreSQL**

```bash
sudo -u postgres createuser --pwprompt jira
sudo -u postgres createdb -O jira jira
```

### **Téléchargement de Jira**

Télécharger Jira depuis Atlassian :

```bash
cd /tmp
wget https://product-downloads.atlassian.com/software/jira/downloads/atlassian-jira-software-9.12.0-x64.bin
```

Adapter la version selon celle disponible.

### **Installation de Jira**

Rendre le fichier exécutable et lancer l'installation :

```bash
chmod +x atlassian-jira-software-9.12.0-x64.bin
sudo ./atlassian-jira-software-9.12.0-x64.bin
```

Suivre l'assistant d'installation :

1. **Chemin d'installation** : Par défaut `/opt/atlassian/jira`
2. **Répertoire de données** : Par défaut `/var/atlassian/application-data/jira`
3. **Port HTTP** : Par défaut `8080`
4. **Démarrage du service** : Cocher pour démarrer automatiquement

## **Configuration**

### **Accès initial à Jira**

Une fois l'installation terminée, accéder à Jira via :

```
http://votre-serveur:8080
```

### **Assistant de configuration**

L'assistant guidera à travers les étapes de configuration initiale :

#### **1. Licence Jira**

- **Essai gratuit** : 30 jours sans license
- **License communautaire** : Pour petites équipes/projets open source
- **License commerciale** : Entrer la clé license

#### **2. Type d'installation**

- **Standalone** : Installation simple sur une machine
- **Cluster** : Pour haute disponibilité (avancé)

#### **3. Configuration de la base de données**

- Sélectionner **PostgreSQL**
- Entrer les détails :
  - **Hostname** : `localhost`
  - **Port** : `5432`
  - **Database** : `jira`
  - **Username** : `jira`
  - **Password** : (mot de passe créé)

#### **4. Utilisateur administrateur**

- **Username** : Créer un administrateur
- **Password** : Mot de passe fort
- **Email** : Adresse email

### **Configuration post-installation**

#### **1. Paramètres généraux**

Aller dans **Settings** > **System**:

- **Site Name** : Nom du serveur Jira
- **Base URL** : URL correcte (important pour l'intégration)
- **Language** : Choisir français
- **Email Notifications** : Configurer le serveur SMTP

#### **2. Création de projets**

Créer des projets selon les besoins :

**Via Settings > Projects > Create Project** :

1. Sélectionner le modèle (**Scrum** ou **Kanban**)
2. Entrer le nom du projet
3. Entrer la clé du projet (ex: **LAB** pour "Laboratory")

#### **3. Configuration des utilisateurs**

Aller dans **Settings > User management** :

- Créer des utilisateurs
- Attribuer les rôles (Developer, Tester, Project Lead, Administrator)
- Créer des groupes

#### **4. Configuration des permissions**

Définir les permissions par projet :

1. Aller dans le projet
2. **Project settings > Permissions**
3. Assigner les rôles aux groupes

### **Configuration Apache en tant que proxy inverse**

```bash
nano /etc/apache2/sites-available/jira.conf
```

**Contenu** :

```apache
<VirtualHost *:80>
    ServerName jira.lab.local
    ServerAdmin admin@lab.local

    ProxyPreserveHost On
    ProxyPass / http://localhost:8080/
    ProxyPassReverse / http://localhost:8080/

    RequestHeader set X-Forwarded-Proto http
    RequestHeader set X-Forwarded-Host jira.lab.local
</VirtualHost>

<VirtualHost *:443>
    ServerName jira.lab.local
    ServerAdmin admin@lab.local

    SSLEngine on
    SSLCertificateFile /etc/ssl/certs/jira.crt
    SSLCertificateKeyFile /etc/ssl/private/jira.key

    ProxyPreserveHost On
    ProxyPass / http://localhost:8080/
    ProxyPassReverse / http://localhost:8080/

    RequestHeader set X-Forwarded-Proto https
    RequestHeader set X-Forwarded-Host jira.lab.local
</VirtualHost>
```

Activer :

```bash
a2ensite jira.conf
a2enmod proxy proxy_http ssl headers
systemctl reload apache2
```

### **Intégration avec Confluence**

Connecter Jira à Confluence pour le flux de travail unifié :

1. Aller dans **Settings > Atlassian Marketplace**
2. Chercher "Confluence Integration"
3. Installer le plugin
4. Configurer l'URL Confluence

### **Connexion avec Git**

Intégrer Jira avec les dépôts Git (GitHub, GitLab, Gitea) :

1. Aller dans **Settings > Integrations > Jira for GitHub**
2. Configurer les webhooks
3. Lier les commits aux tickets Jira

### **Authentification LDAP/AD**

Pour l'authentification centralisée :

1. **Settings > User directories > Add directory**
2. Sélectionner **LDAP**
3. Configurer les paramètres LDAP

### **Sauvegarde**

Créer un script de sauvegarde :

```bash
#!/bin/bash
BACKUP_DIR="/backup/jira"
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p $BACKUP_DIR

# Sauvegarde PostgreSQL
sudo -u postgres pg_dump jira | gzip > $BACKUP_DIR/jira_db_$DATE.sql.gz

# Sauvegarde répertoire de données
tar -czf $BACKUP_DIR/jira_data_$DATE.tar.gz /var/atlassian/application-data/jira

# Garder les 7 dernières sauvegardes
find $BACKUP_DIR -name "jira_*" -mtime +7 -delete
```

Planifier :

```bash
chmod +x /usr/local/bin/jira_backup.sh
echo "0 3 * * * /usr/local/bin/jira_backup.sh" | crontab -
```

## **Utilisation**

### **Créer un ticket**

1. Cliquer sur **Create**
2. Remplir :
   - **Project** : Sélectionner le projet
   - **Issue Type** : Bug, Tâche, Story, Sous-tâche
   - **Summary** : Description brève
   - **Description** : Détails
   - **Assignee** : Assigner à quelqu'un
   - **Priority** : Importance

3. Cliquer **Create**

### **Workflow Scrum**

1. **Planification de sprint** : Ajouter les tickets à faire
2. **Sprint board** : Voir l'état des tâches
3. **Revue de sprint** : Valider les tickets complétés

### **Reporting**

Jira offre des rapports :

- **Sprint report** : Vue d'ensemble du sprint
- **Velocity chart** : Vélocité de l'équipe
- **Burndown chart** : Progression du sprint
- **Cumulative flow** : Flux de travail

## **Maintenance**

### **Logs Jira**

```bash
tail -f /var/atlassian/application-data/jira/logs/catalina.out
```

### **Nettoyage**

Archiver les anciens tickets et projets complétés.

### **Mise à jour**

Télécharger la nouvelle version et relancer l'installation.

## **Troubleshooting**

### **Problème : Jira ne démarre pas**

Vérifier les logs et que PostgreSQL est accessible.

### **Problème : Slow performance**

Vérifier RAM/CPU, augmenter la mémoire heap de Jira dans `setenv.sh`.

### **Problème : Erreur de connexion BD**

Vérifier que PostgreSQL est accessible et que les credentials sont corrects.
