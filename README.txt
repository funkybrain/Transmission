﻿Tips:
----
FP.choose() is your friend

Bugs:
----
> bug with path tileset (couple of random tiles showing at beginning of levels)
>> FIXED: level was wrapping due to width not being an exact multiplier of grid

Next: release 1.5
-----------------


To do list:
----------
> figure out how to handle intersections
> figure out how particles work
> how does flashdev profiler work?

> stress test level size in ogmo and flash

> implement moovesmooth

> preloader!

> center player in right 3rd of screen

> may have to scale hitbox to player size if child is small


> A x min avant la fin du timer:
- fade music out
- fade in death music
- prendre contrôle du joueur et avancer tout droit

> Fin du jeu
- Lancer l'écran de crédit avec possibilité de relancer le jeu

> Intro - prévoir un trigger de lancement des timers quand la joueur arrive au début des chemins

> Afficher compteur de distance (mouloud pour DA/font)

> prévoir god-mode pour faire le LD très vite

> Afficher masque noir sur l'écran
- masque vertical lié au ratio de distance le plus petit (bcp de changements = ouverture)
> freeze all timers when player stops
> Vérifier possibilité de dézoomer l'écran

> how can we load multiple levels and put them end-to-end?
- test loading another level and offsetting all coordinates by width of first level
- refactor code so that world creation and level creation are two seperate things (MAKE BRANCH FIRST!)

Next: release 1.3
-----------------
> ajout du timer GrandChildToEnd pour gerer la fin du jeu (dans gamedata.xml)
> fade out (la mort) du petit-fils implemente (10s avant la fin)
> Ogmo: ajout des icones plus parlantes pour placer les animations
> Ogmo: renomme la couche "object" en "player" (placement du joueur au depart du niveau)
> xfade des musiques entre les 3 chemins implementes (pas facile de confirmer que ça marche vu la similarité des trois sons)
> nouvelles animations de chemins par son altesse Mouloud

Next: release 1.4
-----------------
> masque foncé pour restreindre la vision du joueur lors du déplacement
> fixed bug en debut de partie si le joueur n'avance pas
> refactored path_green, red, blue class so all derive from one Path class
> ajout dans gamedata.xml: debug, timer disparition (mort) du pere
> ajout dans Player et Level le timer de la mort du père
> logique d'apparition/disparition de tous les avatars fonctionne. Reste à faire l'IA du robotFather. !00!
> vitesse de recul = VB dans tous les cas
> possibilité de mettre plusieurs background bout à bout
> gridsize for tilemaps now read from xml file
