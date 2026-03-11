# PostgreSQL

## Présentation

Postgresql est un système de base de données open source

## Objectif d'utilisation

Plusieurs des services utilisés dans le projet nécessitent une base de donnée, a savoir:
- Zabbix
- GLPI
- Jira
- Confluence
Nous allons donc faire une machine avec Postgresql qui contiendra plusieurs bases de données, une par service.

## Ressources nécéssaires

En soit postgres est peu gourmand, mais prévoir quand même 2gb de RAM pour que ça soit fluide.

## Installation

Le site de postgresql met a disposition les installers et tutoriels en fonction de la distribution : https://www.postgresql.org/download/


## Configuration

Si postgres est bien installé:

`createdb mydb` permettra de créer une base de données nommé mydb. Il faut en faire une par service qui en nécessite.

`psql mydb`permet d'accéder a la dites database

Postgres fonctionne en client-serveur, il faudra dans chaque database créer un utilisateur qui sera a disposition du dit client, et y accorder les privilèges


Après y avoir accédé: 

Créer l'utilisateur:

`CREATE USER name` 

Accorder les droits sur la database:

