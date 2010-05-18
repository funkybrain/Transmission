Bugs:
----
> bug with path tileset (couple of random tiles showing at beginning of levels)
>> FIXED: level was wrapping due to width not being an exact multiplier of grid

> does SFX.Crossfade automatically start sounds or do i need to start them manually?


Next: release 1.4
-----------------
> 


To do list:
----------
> figure out how to handle intersections
> figure out how particles work
> how does flashdev profiler work?

> get grid size from xml to stay flexible
> stress test level size in ogmo and flash
> implement moovesmooth

> add variable dark mask (restricting player view)
> center player in right 3rd of screen


> may have to scale hitbox to player size if child is small
> refactor paths so that they all derive from one class

> A x min avant la fin du timer:
- fade music out
- fade in death music
- prendre contrôle du joueur et avancer tout droit

> Fin du jeu
- Lancer l'écran de crédit avec possibilité de relancer le jeu

> Intro - prévoir un rigger de lancement des timers quand la joueur arrive au début des chemins

> Afficher compteur de distance (mouloud pour DA/font)

> Faire reculer le joueur très lentement
- prévoir god-mode pour faire le LD très vite

> Afficher masque noir sur l'écran
- masque horizontal lié à la vitesse
- masque vertical lié au ratio de distance le plus petit (bcp de changements = ouverture)

> Vérifier possibilité de dézoomer l'écran

> X-fade les musiques des trois chemins

Next: release 1.3
-----------------
> ajout du timer GrandChildToEnd pour gerer la fin du jeu (dans gamedata.xml)
> fade out (la mort) du petit-fils implemente (10s avant la fin)
> Ogmo: ajout des icones plus parlantes pour placer les animations
> Ogmo: renomme la couche "object" en "player" (placement du joueur au depart du niveau)
> xfade des musiques entre les 3 chemins implementes (pas facile de confirmer que ça marche vu la similarité des trois sons)
> nouvelles animations de chemins par son altesse Mouloud
