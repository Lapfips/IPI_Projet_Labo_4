Petit disclaimer, cette documentation concerne l'installation d'un serveur zabbix tout en un avec apache et postgresql également installé sur la même machine.

# Zabbix

## Présentation
Zabbix est un outil de supervision, il surveille le bon fonctionnement des terminaux sous sa tutelle. 
A l'aide de son dashboard, il permet de visualiser des métriques a mesurer et créer des alertes en cas de malfonction.

## Objectif d'utilisation

L'interet de Zabbix, c'est tout simplement de surveiller une machine, si possible agir avant qu'un disfonctionnement arrive et surtout d'en être bien informé.

## Ressources nécéssaires

Pour un serveur zabbix complet, prévoir optimalement:

CPU — 2 vCPUs

RAM — 4 Go, 2Go fonctionneront si il y a peu de machine a surveiller.

Disque — 50 Go

## Installation + Configuration

Sur Débian:

# 1. Ajout du dépôt Zabbix (si jamais le copier/coller ne passe pas, lancer les ligne individuellement, si il y a des soucis de permission penser a sudo.)

```bash
wget https://repo.zabbix.com/zabbix/7.0/debian/pool/main/z/zabbix-release/zabbix-release_latest_7.0+debian12_all.deb
dpkg -i zabbix-release_latest_7.0+debian12_all.deb
apt update
```

# 2. Installation des paquets 

```bash
apt install zabbix-server-pgsql zabbix-frontend-php php8.2-pgsql \
            zabbix-apache-conf zabbix-sql-scripts zabbix-agent postgresql -y
```
# 3. Configuration de la base de données

Créer l'utilisateur et la base PostgreSQL :

```bash
sudo -u postgres createuser --pwprompt zabbix
sudo -u postgres createdb -O zabbix zabbix
```

Importer les tables initiales :

```bash
zcat /usr/share/zabbix-sql-scripts/postgresql/server.sql.gz | sudo -u zabbix psql zabbix
```

# 4. Configuration du serveur Zabbix

```bash
nano /etc/zabbix/zabbix_server.conf
```

Modifier ces lignes et les décommenter.

```
DBHost=localhost
DBName=zabbix
DBUser=zabbix
DBPassword=mot de passe de la database
```

# 5. Démarrage des services

```bash
systemctl restart zabbix-server zabbix-agent apache2
systemctl enable zabbix-server zabbix-agent apache2
```

Vérifier que tout est actif :

```bash
systemctl status zabbix-server
```

## 6. Accès à l'interface web

Ouvrir un navigateur et aller sur :

```
http://ip-du-serveur/zabbix
```

Suivre l'assistant de configuration :
- **Database type** : PostgreSQL
- **Database host** : localhost
- **Database name** : zabbix
- **User / Password** : zabbix / ton_mot_de_passe

Identifiants par défaut : `Admin` / `zabbix`

Zabbix est maintenant en service.

Pour ajouter un terminal:

## Installation de l'agent zabbix

Sur la machine cible:

```bash
apt install zabbix-agent -y
```

Puis configurer /etc/zabbix/zabbix_agentd.conf

```bash
Server=IP_DU_SERVEUR_ZABBIX
Hostname=nom_de_la_machine
ServerActive=IP_DU_SERVEUR_ZABBIX
```

Puis relancer le service

```bash
systemctl enable zabbix-agent
systemctl start zabbix-agent
```

Enfin, il faudra ajouter la machine sur l'interface web de zabbix, dans hote, créer un hote.

Interface = agent 

et renseigner l'ip
