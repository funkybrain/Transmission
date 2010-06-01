Tips:
----
FP.choose() is your friend
Embedding assets: http://www.bit-101.com/blog/?p=853
Define a private Class variable, put the cursor just above it and right-click click on your image, insert to document:
>FlashDevelop will automatically insert the correct “Embed” tag in your code.


Bugs:
----
> bug with path tileset (couple of random tiles showing at beginning of levels)
>> FIXED: level was wrapping due to width not being an exact multiplier of grid

> Monster random bug
>> seems like moved player outside a path, and therefore returns a null entity on collision
>> is there a spike in distance to move to (e.g. during a transmission)?
>> happens for child and grandchild (maybe father, need confirmation)
>> detected at x:1043.65, y: 183.01
>> detected at x:551.06, y: 195.87
>> detected at x:521.70, y: 196.93

Next: release 1.6
--------------------
> mis en place les bases de l'algorithme de pathfinding A*
> ajout d'une variable LD pour basculer entre vrai LD et LD de debuggage (pour manu) 
> ajout du fade-in au debut du jeu (class Curtain)
> mis en place de la fonctionalite pour lire une video d'intro (class Intro) avant de commencer le jeu
>> attention: tapper sur "Enter" pour demarrer le jeu en fin de fondu
> ajout du menu de fin (placeholder) et redémarrage du jeu avec ENTER
> ajout fade to black en fin de jeu, avant affichage du menu
> ajout du rouleau qui est poussé par le joueur
> scale-up du sprite du fils (1 à 1.5) pendant son cycle de vie
> Fade-out/in du son lorsque le joueur se déplace (coupure n'est plus abrupte)
> Arret du rouleau lorsque la sequence de mort du petit fils commence (fade-out du sprite du petit fils - 10 sec)
> Ajout des animations de fond crash et prison

> cleaned up pathTileList<PathTile> to save memory
> created Epitaphe class to handle final text

To do list:
----------
> can we avoid the slowdown when player only crosses path without changing?
> implement moovesmooth
> preloader!
> center player in right 3rd of screen?
> may have to scale hitbox to player size if child is small
> A x min avant la fin du timer:
- fade music out
- fade in death music
- prendre contrôle du joueur et avancer tout droit

> Afficher masque noir sur l'écran
- masque vertical lié au ratio de distance le plus petit (bcp de changements = ouverture)

> Vérifier possibilité de dézoomer l'écran (ok)

> Test loading another level and offsetting all coordinates by width of first level

=====================================================================================
PREVIOUS RELEASES

Release 1.3
-----------------
> ajout du timer GrandChildToEnd pour gerer la fin du jeu (dans gamedata.xml)
> fade out (la mort) du petit-fils implemente (10s avant la fin)
> Ogmo: ajout des icones plus parlantes pour placer les animations
> Ogmo: renomme la couche "object" en "player" (placement du joueur au depart du niveau)
> xfade des musiques entre les 3 chemins implementes (pas facile de confirmer que ça marche vu la similarité des trois sons)
> nouvelles animations de chemins par son altesse Mouloud

Release 1.4
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

Release 1.5
-----------------
> tous les compteurs de temps s'arretent lorsque le joueur ne bouge pas
> tous les sons s'arrettent lorsque le joueur est immobile
> nouvelles formules de transmissions implementees pour les trois generations!
> smoothed acceleration with FP.elapsed
> refactored world ceation (now Game class does the logic, and Level only loads level data)
> god mode pour se deplacer rapidement dans le niveau (ajoute a gamedata)