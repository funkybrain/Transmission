To do list:
> figure out how to handle intersections
> work out distance traveled on each path
> figure out how particles work
> get grid size from xml to stay flexible
> put the three grid layers next to each other in order to easily draw the collision masks

Architecture
------------

3 Entities that handle the three paths:

> have a Path entoty that handles common stuff for all paths

> public class RedPath extends Entity
>> has Tilemap and Grid for collision

> public class BluePath extends Entity
> public class GreenPath extends Entity

N Entities that handle intersections???
> public class Intersection extends Entity


1 Entity that handles the cosmetics:

> public class Design extends Entity
>> has Tilemap - collisions not needed?

1 Entity that handles basic movement and collision
> public class Moveable extends Entity

1 Entity that handles Player
> public class Player extends Moveable
> has properties for speed, alarm, distance travelled, type (father, son, grandson)
> has graphic = Spritemap to play animations

N entities that handle cosmetic animations
> public class Animations extends Entity
> has graphic = Spritemap to play animations


