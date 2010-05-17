Bugs:
----
> bug with path tileset (couple of random tiles showing at beginning of levels)
>> FIXED: level was wrapping due to width not being an exact multiplier of grid

To do list:
----------
> figure out how to handle intersections
> figure out how particles work
> get grid size from xml to stay flexible
> stress test level size in ogmo and flash
> implement moovesmooth
> how does flashdev profiler work?
> add variable dark mask (restricting player view)
> center player in right 3rd of screen
> scale animation framerate to player speed

> may have to scale hitbox to player size if child is small
> refactor paths so that they all derive from one class

Architecture
------------

3 Entities that handle the three paths:

> have a Path entoty that handles common stuff for all paths

1 Entity that handles the cosmetics:

> public class Design extends Entity
>> has Tilemap - collisions not needed?
>> use graphic list?

1 Entity that handles Player
> public class Player extends Moveable
> has properties for speed, alarm, distance travelled, type (father, son, grandson)
> has graphic = Spritemap to play animations

N entities that handle cosmetic animations
> public class Animations extends Entity
> has graphic = Spritemap to play animations