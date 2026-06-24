# **`Apache`**

## **Présentation**

**`Apache HTTP Server`** (aussi connu sous le nom d'**`Apache`** ou **`httpd`**) est un serveur web open source multiplateforme. C'est l'un des serveurs web les plus populaires et les plus utilisés au monde. Il est hautement configurable et extensible via des modules, permettant de supporter divers protocoles et technologies (**`PHP`**, **`CGI`**, **`SSL/TLS`**, etc.).

## **Objectif d'utilisation**

Dans ce projet, **`Apache`** est utilisé pour héberger les interfaces web de plusieurs services :

- **`Zabbix`** : plateforme de supervision et monitoring
- **`GLPI`** : gestion d'inventaire IT et helpdesk
- **`Nextcloud`** : stockage et partage de fichiers en cloud

## **Ressources nécessaires**

| Ressource              | Minimum                | Recommandé             |
| ---------------------- | ---------------------- | ---------------------- |
| CPU                    | 1 vCPU                 | 2 vCPU                 |
| RAM                    | 512 MB                 | 1-2 GB                 |
| Disque                 | 2 GB                   | 10 GB                  |
| Réseau                 | 1 interface            | 1 interface            |
| Système d'exploitation | Debian 12 ou AlmaLinux | Debian 12 ou AlmaLinux |

Avant de commencer, vérifier que les ressources suivantes sont disponibles :

- Une machine virtuelle Debian ou AlmaLinux fonctionnelle
- Accès root ou droits sudo
- Connexion internet pour télécharger les paquets

## **Installation**

### **`Debian`**

Mettre à jour le système :

```bash
apt update
apt upgrade -y
```

Installer **`Apache`** et les extensions nécessaires :

```bash
apt install apache2 apache2-utils -y
```

Installer les modules **`PHP`** et autres dépendances selon les besoins :

```bash
apt install libapache2-mod-php php-cli php-curl php-gd php-xml php-mbstring php-mysql -y
```

Vérifier que **`Apache`** est installé :

```bash
apache2 -v
```

### **`AlmaLinux / Red Hat`**

Mettre à jour le système :

```bash
dnf update
dnf upgrade -y
```

Installer **`Apache`** et les extensions nécessaires :

```bash
dnf install httpd httpd-tools -y
```

Installer les modules **`PHP`** et autres dépendances selon les besoins :

```bash
dnf install php php-cli php-curl php-gd php-xml php-mbstring php-mysql -y
```

Vérifier que **`Apache`** est installé :

```bash
httpd -v
```

## **Configuration**

### **Démarrage du service**

**Debian** :

```bash
systemctl start apache2
systemctl enable apache2
systemctl status apache2
```

**AlmaLinux** :

```bash
systemctl start httpd
systemctl enable httpd
systemctl status httpd
```

### **Configuration des hôtes virtuels**

Apache utilise des fichiers de configuration d'hôtes virtuels pour gérer plusieurs sites ou applications sur un même serveur.

**Debian** - Créer un fichier de configuration :

```bash
nano /etc/apache2/sites-available/myapp.conf
```

**Exemple de configuration basique** :

```apache
<VirtualHost *:80>
    ServerName myapp.example.com
    ServerAdmin admin@example.com

    DocumentRoot /var/www/myapp

    <Directory /var/www/myapp>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/myapp_error.log
    CustomLog ${APACHE_LOG_DIR}/myapp_access.log combined
</VirtualHost>
```

**Activer l'hôte virtuel (Debian)** :

```bash
a2ensite myapp.conf
a2enmod rewrite
systemctl reload apache2
```

**AlmaLinux** - Créer un fichier de configuration dans `/etc/httpd/conf.d/myapp.conf` et recharger :

```bash
systemctl reload httpd
```

### **Activation des modules essentiels**

**Debian** - Activer les modules couramment utilisés :

```bash
a2enmod rewrite          # Pour la réécriture d'URL
a2enmod ssl              # Pour HTTPS
a2enmod proxy            # Pour la mise en cache proxy
a2enmod proxy_http       # Pour les requêtes proxy HTTP
a2enmod headers          # Pour la gestion des en-têtes
```

**AlmaLinux** - Les modules sont généralement activés par défaut ou configurés dans `/etc/httpd/conf.modules.d/`

### **Configuration HTTPS/SSL**

Pour sécuriser les connexions, générer un certificat autosigné ou utiliser un certificat valide :

**Générer un certificat autosigné (pour test uniquement)** :

```bash
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /etc/ssl/private/myapp.key \
  -out /etc/ssl/certs/myapp.crt
```

**Ajouter HTTPS à la configuration** :

```apache
<VirtualHost *:443>
    ServerName myapp.example.com

    SSLEngine on
    SSLCertificateFile /etc/ssl/certs/myapp.crt
    SSLCertificateKeyFile /etc/ssl/private/myapp.key

    DocumentRoot /var/www/myapp
    # ... reste de la configuration
</VirtualHost>

# Redirection HTTP vers HTTPS
<VirtualHost *:80>
    ServerName myapp.example.com
    Redirect / https://myapp.example.com/
</VirtualHost>
```

### **Vérifier la configuration**

Avant de recharger Apache, vérifier la syntaxe de configuration :

**Debian** :

```bash
apache2ctl configtest
```

**AlmaLinux** :

```bash
httpd -t
```

La réponse doit être `Syntax OK`.

### **Logs et monitoring**

Les logs Apache se trouvent généralement à :

**Debian** : `/var/log/apache2/`

**AlmaLinux** : `/var/log/httpd/`

Consulter les logs :

```bash
tail -f /var/log/apache2/access.log    # Debian
tail -f /var/log/httpd/access_log      # AlmaLinux
```

## **Utilisation avec les services du projet**

Pour chaque service web (Zabbix, GLPI, Nextcloud), créer un hôte virtuel dédié et adapter la configuration en fonction des besoins spécifiques du service.

Exemple : voir la documentation respective de chaque service pour les configurations Apache recommandées.
