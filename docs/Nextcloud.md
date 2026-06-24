# **`Nextcloud`**

## **Présentation**

**`Nextcloud`** est une suite de collaboration open source qui offre un stockage et partage de fichiers sécurisés, avec support pour la synchronisation, l'édition collaborative de documents, la messagerie, le calendrier et les tâches. C'est une alternative auto-hébergée à Dropbox, OneDrive et Google Drive.

Nextcloud est basée sur **PHP** et peut utiliser **MySQL**, **PostgreSQL** ou **SQLite** comme base de données.

## **Objectif d'utilisation**

Dans ce projet, Nextcloud est utilisé pour :

- **Stockage centralisé** : Espace de partage de fichiers pour l'équipe du labo
- **Synchronisation fichiers** : Clients de synchronisation pour Windows, Mac, Linux
- **Collaboration** : Partage et co-édition de documents
- **Sauvegardes** : Archivage de fichiers de configuration et documentations
- **Accessibilité** : Accès depuis n'importe quel endroit via web

## **Ressources nécessaires**

| Ressource              | Minimum                    | Recommandé          |
| ---------------------- | -------------------------- | ------------------- |
| CPU                    | 1 vCPU                     | 2 vCPU              |
| RAM                    | 1 GB                       | 2-4 GB              |
| Disque                 | 50 GB                      | 100+ GB             |
| Système d'exploitation | Debian 12                  | Debian 12           |
| Serveur web            | Apache                     | Apache avec mod_php |
| Base de données        | PostgreSQL 12+ ou MySQL 8+ | PostgreSQL 12+      |
| PHP                    | 8.0+                       | 8.1+                |
| Stockage               | Disque interne/NAS         | Disque dédié rapide |

Avant de commencer :

- Machine virtuelle Debian 12
- Apache web server installé
- PostgreSQL installé et fonctionnel
- PHP 8.1+ avec extensions
- Accès root/sudo
- Connexion internet
- Stockage suffisant pour les données

## **Installation**

### **Prérequis - Extensions PHP**

Installer PHP et les extensions nécessaires :

```bash
apt update
apt install php8.1-cli php8.1-common php8.1-curl php8.1-fpm php8.1-gd \
            php8.1-gmp php8.1-imap php8.1-intl php8.1-mbstring php8.1-mysql \
            php8.1-opcache php8.1-pgsql php8.1-redis php8.1-xml php8.1-zip \
            php8.1-bcmath php8.1-bz2 -y
```

Installer des paquets supplémentaires utiles :

```bash
apt install apache2 apache2-utils libapache2-mod-php8.1 -y
apt install postgresql postgresql-client -y
apt install imagemagick ffmpeg redis-server -y
```

### **Création de la base de données PostgreSQL**

Créer l'utilisateur et la base de données :

```bash
sudo -u postgres createuser --pwprompt nextcloud
sudo -u postgres createdb -O nextcloud nextcloud
```

### **Téléchargement de Nextcloud**

Télécharger Nextcloud depuis le site officiel :

```bash
cd /var/www/html
wget https://download.nextcloud.com/server/releases/latest.tar.bz2
tar -xjf latest.tar.bz2
rm latest.tar.bz2
```

Adapter les permissions :

```bash
chown -R www-data:www-data /var/www/html/nextcloud
chmod 755 /var/www/html/nextcloud
```

### **Configuration Apache**

Créer un fichier de configuration pour Nextcloud :

```bash
nano /etc/apache2/sites-available/nextcloud.conf
```

**Contenu** :

```apache
<VirtualHost *:80>
    ServerName nextcloud.lab.local
    ServerAdmin admin@lab.local

    DocumentRoot /var/www/html/nextcloud

    <Directory /var/www/html/nextcloud>
        Options FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    <IfModule mod_headers.c>
        Header always set Strict-Transport-Security "max-age=31536000; includeSubDomains"
        Header always set X-Content-Type-Options "nosniff"
        Header always set X-Frame-Options "SAMEORIGIN"
        Header always set X-XSS-Protection "1; mode=block"
    </IfModule>

    ErrorLog ${APACHE_LOG_DIR}/nextcloud_error.log
    CustomLog ${APACHE_LOG_DIR}/nextcloud_access.log combined
</VirtualHost>
```

Activer la configuration et les modules nécessaires :

```bash
a2ensite nextcloud.conf
a2enmod rewrite
a2enmod headers
a2enmod env
a2enmod ssl
a2enmod dir
a2enmod mime
systemctl reload apache2
```

## **Configuration**

### **Accès initial à Nextcloud**

Accéder à Nextcloud via : `http://nextcloud.lab.local`

### **Assistant d'installation**

L'assistant vous guidera à travers la configuration :

#### **1. Créer un compte administrateur**

- **Utilisateur** : `admin`
- **Mot de passe** : Mot de passe fort

#### **2. Finition de l'installation**

Avant de finaliser, configurer la base de données :

**Type de base de données** : PostgreSQL

**Paramètres** :

- **Utilisateur BDD** : `nextcloud`
- **Mot de passe BDD** : (le mot de passe défini)
- **Nom BDD** : `nextcloud`
- **Serveur BDD** : `localhost`
- **Port BDD** : `5432`

**Répertoire de données** : `/var/www/html/nextcloud/data`

Cliquer **Terminer l'installation**.

### **Configuration post-installation**

Une fois logué en tant qu'administrateur, effectuer la configuration :

#### **1. Paramètres généraux**

Aller dans **Paramètres** > **Général** :

- **Nom du serveur** : `Nextcloud Lab`
- **Adresse email administrateur** : (adresse email)
- **Fuseau horaire** : Europe/Paris
- **Langue par défaut** : Français

#### **2. Sécurité**

**Paramètres > Sécurité** :

- **Activer la 2FA** (authentification deux facteurs) : Recommandé
- **Whitelist d'IP** : Optionnel
- **Rate limiting** : Activé

#### **3. Base de données**

**Paramètres > Sécurité** :

- Vérifier que la base de données PostgreSQL est bien configurée

#### **4. Performance et cache**

**Paramètres > Administration > Système** :

- **Cache fichiers** : APCu (recommandé)
- **Cache de mémoire locale** : Redis (si installé)

Configuration Redis :

```bash
# Installer Redis (déjà fait dans les prérequis)
systemctl start redis-server
systemctl enable redis-server
```

Éditer `/var/www/html/nextcloud/config/config.php` pour activer Redis :

```php
'memcache.local' => '\OC\Memcache\APCu',
'memcache.distributed' => '\OC\Memcache\Redis',
'redis' => array(
    'host' => 'localhost',
    'port' => 6379,
),
```

#### **5. Répertoire de données externe (optionnel)**

Pour utiliser un stockage externe (NAS, autre disque) :

1. Monter le stockage
2. **Paramètres > Administration > Stockage externe**
3. Ajouter le chemin du stockage

### **Configuration HTTPS/SSL**

Pour sécuriser les connexions, configurer HTTPS :

Générer un certificat autosigné :

```bash
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /etc/ssl/private/nextcloud.key \
  -out /etc/ssl/certs/nextcloud.crt
```

Ajouter à la configuration Apache (`/etc/apache2/sites-available/nextcloud.conf`) :

```apache
<VirtualHost *:443>
    ServerName nextcloud.lab.local
    ServerAdmin admin@lab.local

    SSLEngine on
    SSLCertificateFile /etc/ssl/certs/nextcloud.crt
    SSLCertificateKeyFile /etc/ssl/private/nextcloud.key

    DocumentRoot /var/www/html/nextcloud
    # ... reste de la configuration
</VirtualHost>

# Redirection HTTP vers HTTPS
<VirtualHost *:80>
    ServerName nextcloud.lab.local
    Redirect permanent / https://nextcloud.lab.local/
</VirtualHost>
```

Activer HTTPS :

```bash
a2enmod ssl
systemctl reload apache2
```

### **Création des utilisateurs**

Créer des utilisateurs pour accéder à Nextcloud :

1. Aller dans **Paramètres > Utilisateurs** (en tant qu'admin)
2. Cliquer sur **Nouvel utilisateur**
3. Entrer :
   - **Nom d'utilisateur**
   - **Mot de passe**
   - **Groupes** : Assigner aux groupes appropriés
4. Cliquer **Créer**

### **Configuration des groupes**

Créer des groupes pour organiser les utilisateurs :

1. **Paramètres > Utilisateurs > Groupes**
2. Cliquer sur **Créer un groupe**
3. Entrer le nom du groupe
4. Ajouter des utilisateurs au groupe

### **Partage de fichiers**

Les utilisateurs peuvent partager des fichiers et dossiers :

1. Dans Nextcloud, faire clic-droit sur un fichier/dossier
2. **Partager**
3. Ajouter des utilisateurs ou des groupes
4. Configurer les permissions (lecture, création, édition, suppression)

### **Synchronisation de fichiers (Clients Nextcloud)**

Les utilisateurs peuvent synchroniser des fichiers depuis leurs ordinateurs :

1. Télécharger le client Nextcloud : https://nextcloud.com/install/#install-clients
2. Installer sur Windows, Mac ou Linux
3. Configurer l'accès au serveur Nextcloud
4. Synchroniser les dossiers

### **Applications/Extensions**

Ajouter des fonctionnalités supplémentaires via les applications :

**Paramètres > Apps** :

- **Collabora Online** : Édition collaborative de documents
- **Calendar** : Calendrier partagé
- **Contacts** : Carnet d'adresses
- **Mail** : Client mail
- **Tasks** : Gestion de tâches

Installez l'application Collabora pour l'édition collaborative :

```bash
# Dans l'interface web
Paramètres > Apps > Productivité > Collabora Online > Installer
```

### **Sauvegarde et maintenance**

Créer un script de sauvegarde :

```bash
#!/bin/bash
BACKUP_DIR="/backup/nextcloud"
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p $BACKUP_DIR

# Mettre Nextcloud en mode maintenance
sudo -u www-data php /var/www/html/nextcloud/occ maintenance:mode --on

# Sauvegarde PostgreSQL
sudo -u postgres pg_dump nextcloud | gzip > $BACKUP_DIR/nextcloud_db_$DATE.sql.gz

# Sauvegarde configuration et apps
tar -czf $BACKUP_DIR/nextcloud_config_$DATE.tar.gz \
    /var/www/html/nextcloud/config \
    /var/www/html/nextcloud/apps

# Optionnel : Sauvegarde données (si pas de stockage externe)
# tar -czf $BACKUP_DIR/nextcloud_data_$DATE.tar.gz /var/www/html/nextcloud/data

# Désactiver le mode maintenance
sudo -u www-data php /var/www/html/nextcloud/occ maintenance:mode --off

# Garder les 7 dernières sauvegardes
find $BACKUP_DIR -name "nextcloud_*" -mtime +7 -delete
```

Planifier la sauvegarde :

```bash
chmod +x /usr/local/bin/nextcloud_backup.sh
echo "0 2 * * * /usr/local/bin/nextcloud_backup.sh" | crontab -
```

### **Tâches d'entretien**

Exécuter régulièrement :

```bash
# Nettoyage des anciennes sessions
sudo -u www-data php /var/www/html/nextcloud/occ maintenance:repair

# Optimisation base de données
sudo -u www-data php /var/www/html/nextcloud/occ db:convert-filecache-bigint

# Scanner des fichiers
sudo -u www-data php /var/www/html/nextcloud/occ files:scan --all
```

## **Utilisation**

### **Interface web**

Accédez à Nextcloud via `https://nextcloud.lab.local`

### **Partage sécurisé**

1. **Créer un lien de partage** : Clic droit > Partager > Créer un lien
2. **Protéger par mot de passe** : Ajouter une protection
3. **Définir une expiration** : Lien valide jusqu'à une date

## **Maintenance et monitoring**

### **Logs Nextcloud**

```bash
tail -f /var/www/html/nextcloud/data/nextcloud.log
```

### **Espace disque**

Vérifier l'utilisation disque :

```bash
df -h /var/www/html/nextcloud/data
```

Archiver ou nettoyer les fichiers anciens si nécessaire.

### **Mise à jour Nextcloud**

Mettre à jour via l'interface web ou en ligne de commande :

```bash
sudo -u www-data php /var/www/html/nextcloud/occ upgrade
```

## **Troubleshooting**

### **Problème : Erreur "Le répertoire de données est invalide"**

Vérifier les permissions du répertoire :

```bash
chown -R www-data:www-data /var/www/html/nextcloud/data
chmod 770 /var/www/html/nextcloud/data
```

### **Problème : Performance lente**

- Augmenter RAM
- Activer Redis pour le cache
- Vérifier la taille de la base de données
- Nettoyer les fichiers temporaires

### **Problème : Synchronisation ne fonctionne pas**

- Vérifier la connectivité réseau
- Redémarrer le client Nextcloud
- Vérifier les permissions utilisateur
- Consulter les logs du client
