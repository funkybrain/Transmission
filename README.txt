Bugs:
----
> bug with path tileset (couple of random tiles showing at beginning of levels)
>> FIXED: level was wrapping due to width not being an exact multiplier of grid

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
> scale animation framerate to player speed

> may have to scale hitbox to player size if child is small
> refactor paths so that they all derive from one class

> Ajouter un timer grandChild pour la fin de jeu
> A x min avant la fin du timer:
- fade music out
- fade in death music
- prendre contrôle du joueur et avancer tout droit
- fade player out
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
