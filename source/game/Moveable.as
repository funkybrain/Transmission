package game 
{
	import flash.geom.Point;
	import net.flashpunk.Entity;
	import net.flashpunk.FP;
	
	/**
	 * Base class for moving Entities to handle collision.
	 */
	public class Moveable extends Entity
	{
		/**
		 * Entity -type- to consider solid when colliding.
		 */
		public var pathCollideType:Array = new Array("red", "green", "blue");
		
		
		/**
		 * Movement variables.
		 */
		public var pathMaxVel:Array = new Array(3); // max velocity on each path type
		public var position:Point; // use vectors to do all the cool movement calculations
		
		/**
		 * Game (transmission) specific variables.
		 */
		public var pathBaseSpeed:Array = new Array(3);; // basic speed modifier on each path
		public var totaldistance:Number; // total distance traveled on all paths
		public var pathDistance:Array = new Array(3); // distance travelled on each path
		public var pathDistToTotalRatio:Array = new Array(3); // ratio of distance travelled on each path by total distance
		 
		/**
		 * Constructor.
		 */
		public function Moveable() 
		{
			position = new Point(this.x, this.y); // set the position as the entity's x,y properties
		}
		
		/**
		 * getCurrentType finds out what path the player is standing on,
		 * and returns the value of that path (uint) that will be used in
		 * e.g. pathMaxVel[] array 
		 */
		public function getCurrentPath():uint
		{
			var e:Entity, type:String, pathType:uint;
			e = collideTypes(pathCollideType, x, y);
			
			switch (e.type)
			{
			case "red":
				pathType = 0;
				break;
			case "green":
				pathType = 1;
				break;
			case "blue":
				pathType = 2;
				break;
			}
			//trace(pathType);
			return pathType;
		}
		
		
		
		/**
		 * Moves the entity by the specified amount horizontally and vertically.
		 */
		public function move(moveX:Number = 0, moveY:Number = 0):void
		{
			// movement counters
			
			//_moveX += moveX;
			//_moveY += moveY;
			//moveX = Math.round(_moveX);
			//moveY = Math.round(_moveY);
			//_moveX -= moveX;
			//_moveY -= moveY;
			moveX = Math.round(moveX);
			moveY = Math.round(moveY);
			//trace("moveX: "+ moveX+ " moveY: "+ moveY );
			
			
			
			// movement vars
			var sign:int, e:Entity;
			
			// horizontal
			if (moveX != 0)
			{
				sign = moveX > 0 ? 1 : -1;
				
				while (moveX != 0) //BUG: (not a bug - note) this is a WHILE you dork, that's why it loops
				{
					moveX -= sign;// and hence the reason you decrease moveX which acts as a counter
					
					if ((e = collideTypes(pathCollideType, x + sign, y)))
					{
						//collideX(e);
						x += sign;
						
					}
					else {						
						moveX = 0;
					}
				}
				position.x = x;
			}
			
			// vertical
			if (moveY != 0)
			{
				sign = moveY > 0 ? 1 : -1;
				while (moveY != 0)
				{
					moveY -= sign;
					if ((e = collideTypes(pathCollideType, x, y + sign)))
					{
						//collideY(e);
						y += sign;
					}
					else {
						moveY = 0;						
					}
				}
				position.y = y;
			}
			
			//trace(position);
		}
		
		/**
		 * Horizontal collision (override for specific behaviour).
		 */
		protected function collideX(e:Entity):void
		{
			
		}
		
		/**
		 * Vertical collision (override for specific behaviour).
		 */
		protected function collideY(e:Entity):void
		{
			
		}
		
		/**
		 * Helper vars used by move().
		 */
		//private var _moveX:Number = 0;
		//private var _moveY:Number = 0;
	}
}