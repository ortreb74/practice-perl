## Description du script repcnt.pl

Le script repcnt.pl a une organisation canonique : pas vraiment parce qu'il n'y a pas de structure au milieu

1. Il lance une commande _système_ (ou plus ou moins système) pour obtenir des informations sur le système de fichier
2. Il boucle sur l'ensemble obtenu et applique une expression régulière pour en déduire des informations pour chaque fichier
3. Il utilise 

## Abstract

Il s'agit d'une requête canonique sur le système de fichier. Sa limite est que la commande système rend le résultat pour un répertoire

## Besoins modulés

Je veux connaitre la liste des fichiers qui ne pourront pas être modifiés par un programme