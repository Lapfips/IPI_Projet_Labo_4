# **`Guacamole`**

## **Présentation**

**`Apache Guacamole`** est une application web open source sans client qui permet d'accéder à des ordinateurs distants via les protocoles **`RDP`** (Remote Desktop Protocol), **`SSH`** (Secure Shell) et **`VNC`** (Virtual Network Computing). **`Guacamole`** agit comme un serveur proxy d'accès à distance sans nécessiter l'installation de logiciel client sur la machine locale.

**`Guacamole`** est basée sur **`Java`** avec une interface web développée en **`HTML5`**, utilisant **`WebSockets`** pour la transmission des données de contrôle à distance.

## **Objectif d'utilisation**

Dans ce projet, Guacamole sert de :

- **Bastion/Jump host** : Point d'accès centralisé pour accéder à tous les serveurs du réseau
- **Outil de gestion à distance** : Permettre aux administrateurs d'accéder aux serveurs sans installer de client RDP/SSH
- **Accès web sécurisé** : Accès aux machines via un simple navigateur web
- **Enregistrement des sessions** : Traçabilité des accès pour audit et sécurité

## **Ressources nécessaires**

| Ressource              | Minimum                   | Recommandé     |
| ---------------------- | ------------------------- | -------------- |
| CPU                    | 1 vCPU                    | 2 vCPU         |
| RAM                    | 1 GB                      | 2-4 GB         |
| Disque                 | 10 GB                     | 20 GB          |
| Système d'exploitation | Debian 12                 | Debian 12      |
| Java Runtime           | OpenJDK 11+               | OpenJDK 17+    |
| Tomcat                 | 9.0+                      | 10.0+          |
| Base de données        | PostgreSQL 12+            | PostgreSQL 12+ |
| Navigateur web         | Moderne (Chrome, Firefox) | Moderne        |

Avant de commencer :

- Machine virtuelle Debian fonctionnelle
- Accès à internet pour télécharger les paquets
- PostgreSQL installé et fonctionnel
- Accès root ou droits sudo

## **Installation**

### **Prérequis - Installation de Java et Tomcat**

Installer OpenJDK et Tomcat :

```bash
apt update
apt install openjdk-17-jdk openjdk-17-jre-headless -y
apt install tomcat9 tomcat9-admin -y
```

Vérifier les installations :

```bash
java -version
```

### **Installation de Guacamole Server**

Installer les dépendances de compilation :

```bash
apt install build-essential libcairo2-dev libjpeg62-turbo-dev libpng-dev \
            libossp-uuid-dev libfreerdp-dev libpango1.0-dev libssh2-1-dev \
            libvncserver-dev libssl-dev libvorbis-dev libwebp-dev \
            libpulse-dev automake pkg-config -y
```

Télécharger Guacamole Server :

```bash
cd /tmp
wget https://downloads.apache.org/guacamole/1.5.3/source/guacamole-server-1.5.3.tar.gz
tar xzf guacamole-server-1.5.3.tar.gz
cd guacamole-server-1.5.3
```

Compiler et installer :

```bash
./configure --with-init-dir=/etc/init.d
make
make install
ldconfig
systemctl daemon-reload
```

Vérifier l'installation :

```bash
guacd --version
```

### **Installation de Guacamole Client (WAR)**

Créer le répertoire de configuration de Guacamole :

```bash
mkdir -p /etc/guacamole
mkdir -p /var/log/guacamole
```

Télécharger le fichier WAR de Guacamole :

```bash
cd /tmp
wget https://downloads.apache.org/guacamole/1.5.3/binary/guacamole-1.5.3.war
cp guacamole-1.5.3.war /var/lib/tomcat9/webapps/guacamole.war
```

### **Installation de l'extension PostgreSQL**

Télécharger et installer l'extension PostgreSQL :

```bash
cd /tmp
wget https://downloads.apache.org/guacamole/1.5.3/binary/guacamole-auth-jdbc-1.5.3.tar.gz
tar xzf guacamole-auth-jdbc-1.5.3.tar.gz
cp guacamole-auth-jdbc-1.5.3/postgresql/guacamole-auth-jdbc-postgresql-1.5.3.jar \
   /var/lib/tomcat9/webapps/guacamole/WEB-INF/lib/
```

### **Création de la base de données PostgreSQL**

Créer l'utilisateur et la base :

```bash
sudo -u postgres createuser --pwprompt guacamole
sudo -u postgres createdb -O guacamole guacamole
```

Initialiser le schéma de la base de données :

```bash
cd /tmp
wget https://downloads.apache.org/guacamole/1.5.3/binary/guacamole-auth-jdbc-1.5.3.tar.gz
tar xzf guacamole-auth-jdbc-1.5.3.tar.gz
```

Importer le schéma initial :

```bash
sudo -u postgres psql guacamole < /tmp/guacamole-auth-jdbc-1.5.3/postgresql/schema/001-create-schema.sql
sudo -u postgres psql guacamole < /tmp/guacamole-auth-jdbc-1.5.3/postgresql/schema/002-create-admin-user.sql
sudo -u postgres psql guacamole < /tmp/guacamole-auth-jdbc-1.5.3/postgresql/schema/003-create-admin-user-permissions.sql
```

## **Configuration**

### **Configuration de Guacamole**

Créer le fichier de configuration principal :

```bash
nano /etc/guacamole/guacamole.properties
```

**Contenu** :

```properties
# Configuration PostgreSQL
postgresql-hostname: localhost
postgresql-port: 5432
postgresql-database: guacamole
postgresql-username: guacamole
postgresql-password: VOTRE_MOT_DE_PASSE

# Configuration API
enable-request-logging: true
```

Donner les permissions appropriées :

```bash
chown tomcat9:tomcat9 /etc/guacamole/guacamole.properties
chmod 600 /etc/guacamole/guacamole.properties
```

### **Configuration de Tomcat**

Éditer le fichier de configuration Tomcat pour Guacamole :

```bash
nano /var/lib/tomcat9/webapps/guacamole/WEB-INF/web.xml
```

Ajouter ou vérifier les paramètres de configuration dans la section `<context-param>`.

### **Démarrage des services**

Démarrer guacd (serveur Guacamole) :

```bash
systemctl start guacd
systemctl enable guacd
systemctl status guacd
```

Redémarrer Tomcat :

```bash
systemctl restart tomcat9
systemctl enable tomcat9
systemctl status tomcat9
```

### **Accès initial à Guacamole**

Accéder à Guacamole via `http://votre-serveur:8080/guacamole`

Les identifiants par défaut sont :

- **Utilisateur** : `guacadmin`
- **Mot de passe** : `guacadmin`

### **Changer le mot de passe par défaut**

Une fois logué, aller dans :

- **Paramètres** > **Utilisateurs** > **guacadmin**
- Changer le mot de passe

### **Configuration des connexions distantes**

1. Aller dans **Paramètres** > **Connexions**
2. Cliquer sur **Nouvelle connexion**
3. Configurer les paramètres :

**Exemple pour une connexion SSH** :

```
Nom: serveur-prod
Protocole: SSH
Hostname: 192.168.125.5
Port: 22
Utilisateur: admin
```

**Exemple pour une connexion RDP** :

```
Nom: poste-travail
Protocole: RDP
Hostname: 192.168.125.10
Port: 3389
Utilisateur: user
Domaine: WORKGROUP
```

### **Configuration HTTPS avec Apache (reverse proxy)**

Configurer Apache en tant que reverse proxy devant Tomcat :

```bash
nano /etc/apache2/sites-available/guacamole.conf
```

**Contenu** :

```apache
<VirtualHost *:443>
    ServerName guacamole.lab.local

    SSLEngine on
    SSLCertificateFile /etc/ssl/certs/guacamole.crt
    SSLCertificateKeyFile /etc/ssl/private/guacamole.key

    ProxyPreserveHost On
    ProxyPass / http://localhost:8080/guacamole/
    ProxyPassReverse / http://localhost:8080/guacamole/

    RequestHeader set X-Forwarded-Proto https
    RequestHeader set X-Forwarded-Host guacamole.lab.local
</VirtualHost>

# Redirection HTTP vers HTTPS
<VirtualHost *:80>
    ServerName guacamole.lab.local
    Redirect permanent / https://guacamole.lab.local/
</VirtualHost>
```

Activer la configuration :

```bash
a2ensite guacamole.conf
a2enmod proxy
a2enmod proxy_http
a2enmod ssl
a2enmod headers
systemctl reload apache2
```

### **Configuration de la sauvegarde**

Créer un script de sauvegarde :

```bash
#!/bin/bash
BACKUP_DIR="/backup/guacamole"
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p $BACKUP_DIR

# Sauvegarde PostgreSQL
sudo -u postgres pg_dump guacamole | gzip > $BACKUP_DIR/guacamole_db_$DATE.sql.gz

# Garder les 7 dernières sauvegardes
find $BACKUP_DIR -name "guacamole_*" -mtime +7 -delete
```

Planifier la sauvegarde :

```bash
chmod +x /usr/local/bin/guacamole_backup.sh
echo "0 3 * * * /usr/local/bin/guacamole_backup.sh" | crontab -
```

## **Utilisation**

### **Enregistrement des sessions**

Guacamole enregistre automatiquement les sessions. Pour consulter les sessions :

1. Aller dans **Paramètres** > **Affichage/Connexions**
2. Voir l'historique des connexions

### **Gestion des utilisateurs**

1. Aller dans **Paramètres** > **Utilisateurs**
2. Créer de nouveaux utilisateurs
3. Attribuer les connexions à chaque utilisateur

### **Logs et monitoring**

Consulter les logs de Guacamole :

```bash
tail -f /var/log/guacamole/guacamole.log
journalctl -u guacd -f
```

## **Maintenance**

### **Mise à jour Guacamole**

Pour mettre à jour, télécharger la nouvelle version et refaire les étapes d'installation en remplaçant les fichiers existants.

### **Troubleshooting**

**Problème : Ne pas pouvoir se connecter**

Vérifier que guacd est en cours d'exécution :

```bash
systemctl status guacd
```

Vérifier les logs :

```bash
tail -50 /var/log/guacamole/guacamole.log
```

**Problème : Base de données non accessible**

Vérifier la connexion PostgreSQL :

```bash
psql -h localhost -U guacamole -d guacamole
```
