# **`GLPI`**

## **Présentation**

**`GLPI`** (**`Gestion Libre de Parc Informatique`**) est une application web open source de gestion des actifs informatiques et de gestion de services IT. Elle permet de gérer l'inventaire matériel et logiciel d'une organisation, ainsi que de gérer un système de tickets d'assistance (helpdesk).

**`GLPI`** est basée sur **`PHP`** et utilise une base de données **`MySQL/MariaDB`** ou **`PostgreSQL`** pour stocker ses données.

## **Objectif d'utilisation**

Dans ce projet, GLPI est utilisé pour :

- Maintenir un inventaire centralisé des équipements informatiques (serveurs, postes de travail, matériel réseau)
- Gérer les logiciels et leurs licences
- Gérer les tickets d'assistance utilisateur (création, attribution, suivi)
- Fournir une base de données unique des actifs IT pour toute l'organisation

## **Ressources nécessaires**

| Ressource              | Minimum                    | Recommandé             |
| ---------------------- | -------------------------- | ---------------------- |
| CPU                    | 1 vCPU                     | 2 vCPU                 |
| RAM                    | 1 GB                       | 2-4 GB                 |
| Disque                 | 10 GB                      | 20-50 GB               |
| Système d'exploitation | Debian 12                  | Debian 12 ou AlmaLinux |
| Serveur web            | Apache                     | Apache avec mod_php    |
| Base de données        | PostgreSQL 12+ ou MySQL 8+ | PostgreSQL 12+         |
| PHP                    | 7.4+                       | 8.1+                   |

Avant de commencer :

- Machine virtuelle Debian ou AlmaLinux fonctionnelle
- Apache web server installé et fonctionnel
- PostgreSQL installé et fonctionnel (ou MySQL)
- PHP 8.1+ avec les extensions nécessaires
- Accès root ou droits sudo
- Connexion internet

## **Installation**

### **Prérequis - Extensions PHP**

Installer les extensions PHP requises par GLPI :

**Debian** :

```bash
apt install php-cli php-common php-curl php-dom php-fileinfo \
            php-filter php-gd php-iconv php-intl php-json php-mbstring \
            php-mysqli php-pdo php-pecl-apcu php-simplexml php-xml -y
```

**AlmaLinux** :

```bash
dnf install php-cli php-common php-curl php-dom php-fileinfo \
            php-filter php-gd php-iconv php-intl php-json php-mbstring \
            php-mysqli php-pdo php-pecl-apcu php-simplexml php-xml -y
```

### **Téléchargement et installation de GLPI**

Télécharger la version stable de GLPI depuis le site officiel :

```bash
cd /var/www/html
wget https://github.com/glpi-project/glpi/releases/download/10.0.0/glpi-10.0.0.tgz
tar xzf glpi-10.0.0.tgz
rm glpi-10.0.0.tgz
```

Adapter les permissions :

**Debian** :

```bash
chown -R www-data:www-data /var/www/html/glpi
chmod 755 /var/www/html/glpi
chmod -R 755 /var/www/html/glpi/files
chmod -R 755 /var/www/html/glpi/config
```

**AlmaLinux** :

```bash
chown -R apache:apache /var/www/html/glpi
chmod 755 /var/www/html/glpi
chmod -R 755 /var/www/html/glpi/files
chmod -R 755 /var/www/html/glpi/config
```

### **Création de la base de données PostgreSQL**

Créer l'utilisateur et la base GLPI :

```bash
sudo -u postgres createuser --pwprompt glpi
sudo -u postgres createdb -O glpi glpi
sudo -u postgres psql glpi -c "CREATE EXTENSION unaccent;"
```

### **Configuration Apache**

Créer un fichier de configuration d'hôte virtuel pour GLPI :

```bash
nano /etc/apache2/sites-available/glpi.conf  # Debian
# ou
nano /etc/httpd/conf.d/glpi.conf              # AlmaLinux
```

**Exemple de configuration** :

```apache
<VirtualHost *:80>
    ServerName glpi.lab.local
    ServerAdmin admin@lab.local

    DocumentRoot /var/www/html/glpi/public

    <Directory /var/www/html/glpi/public>
        Options FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    <Directory /var/www/html/glpi>
        Options FollowSymLinks
        AllowOverride None
        Require all denied
    </Directory>

    <FilesMatch \.php$>
        SetHandler application/x-httpd-php
    </FilesMatch>

    ErrorLog ${APACHE_LOG_DIR}/glpi_error.log
    CustomLog ${APACHE_LOG_DIR}/glpi_access.log combined
</VirtualHost>
```

**Debian** - Activer la configuration :

```bash
a2ensite glpi.conf
a2enmod rewrite
systemctl reload apache2
```

**AlmaLinux** - Recharger Apache :

```bash
systemctl reload httpd
```

## **Configuration**

### **Accès à l'installation web**

Accéder à `http://glpi.lab.local/` depuis un navigateur.

**Première étape : Sélection de la langue**

- Choisir la langue (Français recommandé)

**Deuxième étape : Vérification des prérequis**

- L'installateur vérifie les extensions PHP et permissions
- Si tout est OK, continuer

**Troisième étape : Connexion à la base de données**

- Sélectionner PostgreSQL comme type de base de données
- Entrer les détails de connexion :
  - Hôte : `localhost`
  - Utilisateur : `glpi`
  - Mot de passe : (celui défini lors de la création)
  - Base de données : `glpi`

**Quatrième étape : Initialisation de la base de données**

- L'installateur crée les tables GLPI

**Cinquième étape : Choix d'accès**

- Cocher pour installer les données d'exemple (optionnel)

**Sixième étape : Finalisation**

- L'installation est terminée
- Les identifiants par défaut sont :
  - Utilisateur : `glpi`
  - Mot de passe : `glpi`
  - Administrateur : `tech`
  - Mot de passe admin : `tech`

### **Configuration post-installation**

Une fois logué dans GLPI, il est fortement recommandé de :

1. **Changer les mots de passe par défaut**
   - Aller dans : Paramètres > Utilisateurs
   - Modifier les mots de passe pour `glpi` et `tech`

2. **Configurer les paramètres généraux**
   - Aller dans : Configuration > Généralités
   - Configurer le fuseau horaire, la langue par défaut, etc.

3. **Configurer la base de connaissance**
   - Aller dans : Outils > Base de données
   - Créer les structures pour les articles et catégories

4. **Importer les équipements existants**
   - Utiliser les outils d'import disponibles
   - Importer le matériel, les postes de travail, les imprimantes, etc.

### **Configuration HTTPS/SSL**

Pour sécuriser la connexion, ajouter une configuration HTTPS dans le fichier Apache :

```apache
<VirtualHost *:443>
    ServerName glpi.lab.local
    SSLEngine on
    SSLCertificateFile /etc/ssl/certs/glpi.crt
    SSLCertificateKeyFile /etc/ssl/private/glpi.key

    DocumentRoot /var/www/html/glpi/public
    # ... reste de la configuration
</VirtualHost>
```

Générer un certificat autosigné si nécessaire :

```bash
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /etc/ssl/private/glpi.key \
  -out /etc/ssl/certs/glpi.crt
```

### **Configuration de la sauvegarde**

Créer un script de sauvegarde régulière :

```bash
#!/bin/bash
# Script de sauvegarde GLPI

BACKUP_DIR="/backup/glpi"
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p $BACKUP_DIR

# Sauvegarde PostgreSQL
sudo -u postgres pg_dump glpi | gzip > $BACKUP_DIR/glpi_db_$DATE.sql.gz

# Sauvegarde fichiers GLPI
tar -czf $BACKUP_DIR/glpi_files_$DATE.tar.gz /var/www/html/glpi

# Garder seulement les 7 dernières sauvegardes
find $BACKUP_DIR -name "glpi_*" -mtime +7 -delete
```

Rendre le script exécutable et l'ajouter à crontab :

```bash
chmod +x /usr/local/bin/glpi_backup.sh
echo "0 2 * * * /usr/local/bin/glpi_backup.sh" | crontab -
```

## **Utilisation**

### **Accès initial**

Accéder à GLPI via `http://glpi.lab.local` avec les identifiants créés lors de l'installation.

### **Modules principaux**

- **Inventaire** : Gestion des actifs IT (équipements, logiciels, licenses)
- **Assistance** : Gestion des tickets d'assistance utilisateurs
- **Outils** : Base de connaissance, rapports, etc.
- **Configuration** : Paramètres système et utilisateurs

### **Intégration avec Ansible**

GLPI peut être configuré automatiquement par Ansible. Voir le rôle `glpi` pour les détails.

## **Maintenance**

### **Logs GLPI**

Les logs de GLPI se trouvent dans `/var/www/html/glpi/files/_log/`

Consulter les logs :

```bash
tail -f /var/www/html/glpi/files/_log/php-errors.log
```

### **Mise à jour GLPI**

Pour mettre à jour GLPI, télécharger la nouvelle version et suivre les étapes d'installation décrites ci-dessus, en choisissant la base de données existante.
