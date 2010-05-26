Tips:
----
FP.choose() is your friend
Embedding assets: http://www.bit-101.com/blog/?p=853
Define a private Class variable, put the cursor just above it and right-click click on your image, insert to document:
>FlashDevelop will automatically insert the correct “Embed” tag in your code.

To play intro movie:
> must target one symbol in the .swf that contains all other symbols
> make sure the registration point of that symbol is at the top-left corner
> include the fade to black inside last few frames
> also don't forget to tick export as AS in library

Bugs:
----
> bug with path tileset (couple of random tiles showing at beginning of levels)
>> FIXED: level was wrapping due to width not being an exact multiplier of grid

> ajout du fade-in au debut du jeu (class Curtain)
> mis en place de la fonctionalite pour lire une video d'intro (class Intro)


Next: release 1.5
-----------------

> tous les compteurs de temps s'arretent lorsque le joueur ne bouge pas
> tous les sons s'arrettent lorsque le joueur est immobile
> nouvelles formules de transmissions implementees pour les trois generations!

> smoothed acceleration with FP.elapsed
> refactored world ceation (now Game class does the logic, and Level only loads level data)
> god mode pour se deplacer rapidement dans le niveau (ajoute a gamedata)

To do list:
----------
> fade music in/out when player starts/stops
> can we avoid the slowdown when player only crosses path without changing?
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

> Afficher masque noir sur l'écran
- masque vertical lié au ratio de distance le plus petit (bcp de changements = ouverture)

> Vérifier possibilité de dézoomer l'écran

> how can we load multiple levels and put them end-to-end?
- test loading another level and offsetting all coordinates by width of first level

> clean-up assets that are 100 pixels behind camera position

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
