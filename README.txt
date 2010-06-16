Tips:
----
FP.choose() is your friend
Embedding assets: http://www.bit-101.com/blog/?p=853


Bugs:
----
> music comes back when death sequence starts (or at grandchild transmition?), even though volume set to zero
> shutterRight does not close on model 2
> the _overlay timer has a delay when the camera moves. only comes back to right position when stops moving.
this is probably due to the camera trail effect.


Next: release 2.0
-----------------
> nouvelle animation fille -> petit-fils
> modif avatar naissance fille (ajout de couleurs)
> musique credits joue
> compteur apparition du bebe enleve
> quand la mort du petit fils commence, le compteur de temps ne s'arrete plus
> nouveau rouleau
> reglage cache horizontal et vertical selon les 3 modeles de transmission
> nouvelle anim de fond pere-fils
> ajout d'une barre de progression avec un switch dans gamedata.xml
> modif des phases de transmission: duree determinee par valeur dans gamedata
> jingle de transmission activee

To do list:
----------

> can we control framerate playback of embedded swf movies?
> can we avoid the slowdown when player only crosses path without changing?
> implement moovesmooth
> preloader!
> remove tileset to save on memory
> blend shutter textures

> A x min avant la fin du timer:
- fade music out
- fade in death music
- prendre contrôle du joueur et avancer tout droit

> Afficher masque noir sur l'écran
- masque vertical lié au ratio de distance le plus petit (bcp de changements = ouverture)









=====================================================================================
PREVIOUS RELEASES

Release 1.3
-----------
> ajout du timer GrandChildToEnd pour gerer la fin du jeu (dans gamedata.xml)
> fade out (la mort) du petit-fils implemente (10s avant la fin)
> Ogmo: ajout des icones plus parlantes pour placer les animations
> Ogmo: renomme la couche "object" en "player" (placement du joueur au depart du niveau)
> xfade des musiques entre les 3 chemins implementes (pas facile de confirmer que ça marche vu la similarité des trois sons)
> nouvelles animations de chemins par son altesse Mouloud

Release 1.4
-----------
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
-----------
> tous les compteurs de temps s'arretent lorsque le joueur ne bouge pas
> tous les sons s'arrettent lorsque le joueur est immobile
> nouvelles formules de transmissions implementees pour les trois generations!
> smoothed acceleration with FP.elapsed
> refactored world ceation (now Game class does the logic, and Level only loads level data)
> god mode pour se deplacer rapidement dans le niveau (ajoute a gamedata)

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
> Ajout de l'épitaphe (placeholder) qui se déroule à la fin
> Ajout des animations de fond crash et prison

> cleaned up pathTileList<PathTile> to save memory
> created Epitaphe class to handle final text

Next: release 1.7
-----------------
> integre le nouvel avatar fils avec scale inverse
> integre auto-accouchement du fils -> petit fils (avec blocage joueur)
> scaled player animations with fp.elapsed
> ajout des nouveaux coeffs de s-curve pour fils et petit fils, utilisés pour transmission modèle 2
> ajout d'un compteur de temps en overlay
> change la vitesse de recul joueur = 0.1
> doublage du LD avec Level_Romain_2

Next: release 1.8
-----------------
> ajout declencheur de rouleau a placer dans ogmo (layer waypoint, object trigger, actuellement à 6600 sur level 2)
> rouleau se declenche lorsque le joueur atteint la coordonnee du declencheur
> ajout d'un tag <citation> dans gamedata.xml pour changer le mot de la fin
> scale de la fille qui suit le pere
> ajout d'une inertie sur le rouleau

> worked around annoying bug
> recentered all sprite origins and moved hitboxes accordingly
> remove animations and backgrounds that have moved off the screen to save on memory
> fixed bug on animation/path list removal
> added debug traces for major bug

Next: release 1.9
-----------------
> ajout animation serveuse + junky pour LD sur Ogmo
> ajout nouvelle anim crash
> declenchement anim = milieu du sprite
> reglage master volume dans gamedata
> nouvelle texture pour le texte de fond
> nouveau centrage camera lorsque le joueur deroule le texte de fin
> nouvelles animations du pere + fils et mort du pere
> la variable <timeFatherToChild> dans gamedata.xml ne sert plus a rien