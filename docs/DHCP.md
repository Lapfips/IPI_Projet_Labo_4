# **DHCP**

## Présentation

Le DHCP (Dynamic Host Configuration Protocol) est un protocole réseau qui permet d’attribuer automatiquement des adresses IP et d’autres informations réseau (masque, passerelle, DNS) aux machines d’un réseau local.  
Il évite la configuration manuelle de chaque poste et réduit les erreurs d’adressage.

## Objectif d'utilisation

- Fournir automatiquement des adresses IP .  
- Gérer dynamiquement la répartition des adresses pour éviter les conflits IP.  
- Simplifier l’administration du réseau et l’intégration de nouveaux périphériques.  
- Fournir des informations réseau supplémentaires (DNS, passerelle, options spécifiques) aux clients

## Ressources nécéssaires

| Ressource           | Description                                                            |
|--------------------|------------------------------------------------------------------------|
| Serveur Debian 12   | Machine physique ou virtuelle sans interface graphique                |
| 1 interface réseau  | Connectée au réseau interne | 
| Droits root         | Nécessaires pour installer et configurer les services                 |
| Connexion internet  | Pour l’installation du paquet DHCP si nécessaire                      |

## Installation

```bash
sudo apt-get install isc-dhcp-server
```

Arrêter immédiatement après le service afin d’éviter qu’il ne perturbe les services réseaux voisins :

```bash
sudo systemctl stop isc-dhcp-server
```

Vérifier que le service est désactivé avec une commande `systemctl status`

## Configuration

Il faut maintement configurer la plage d'IP utilisable. Pour cela il faut éditer le fichier `/etc/dhcp/dhcpd.conf`:

```bash
ddns-update-style none;

# option definitions common to all supported networks...
option domain-name         "example.com";

# Désactivé pour l'instant: sera activé au moment
# de la mise en place du DNS
#option domain-name-servers 192.168.81.2;

default-lease-time 600;
max-lease-time 7200;

# If this DHCP server is the official DHCP server for the local
# network, the authoritative directive should be uncommented.
authoritative;

# Use this to send dhcp log messages to a different log file (you also
# have to hack syslog.conf to complete the redirection).
log-facility local7;

# No service will be given on this subnet, but declaring it helps the
# DHCP server to understand the network topology.
#subnet 192.168.0.0 netmask 255.255.255.0 {
#}
```

On ajoute le paragraphe suivant:

```bash
subnet 192.168.1.0 netmask 255.255.255.0 {
  authoritative;
  range                       192.168.1.100 192.168.1.200;
  option domain-name-servers  192.168.1.253 ;
  option domain-name          "example.com";
  option routers              192.168.1.254;
  default-lease-time          3600;
  max-lease-time              3600;
  option subnet-mask          255.255.255.0;
  option broadcast-address    192.168.1.255;
}
```

Il faut ensuite redémarrer le service pour que les modifications s'appliquent :

```
sudo systemctl start isc-dhcp-server
```