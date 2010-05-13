Bugs:
----
> fix bug with path tielset (couple of tiles showig at beginning of levels)
>> the display bug in the level may be linked to LF / CRLF conversion???

To do list:
----------
> figure out how to handle intersections
> figure out how particles work
> get grid size from xml to stay flexible
> stress test level size in ogmo and flash
> implement moovesmooth
> grandchild tarnsmission (child does not follow grandchild)
> how the f*** do i make robot child follow father?
> how does flashdev profiler work?
> instead of using father reference, use player but add a state struct with the three states: father, child, grandchild
> add variable dark mask (restricting player view)
> center player in right 3rd of screen
> scale animation framerate to player speed

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