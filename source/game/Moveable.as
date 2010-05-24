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

		public var position:Point; // position vector of player
		public var velocity:Point; // velocity vector of player
		
		/**
		 * Game (transmission) specific variables.
		 */
		public var pathBaseSpeed:Array = new Array(); // basic speed modifier on each path
		public var pathMaxVel:Array = new Array(); // max velocity on each path type
		public var pathInstantVel:Array = new Array(); // the actual velocity used in all movement calculations		
		public var pathFastest:Number; // the maximum speed of all paths
		
		public var totaldistance:Number=0; // total distance traveled on all paths
		public var pathDistance:Array = new Array(); // distance travelled on each path
		public var pathDistToTotalRatio:Array = new Array(); // ratio of distance travelled on each path by total distance
		 
		/**
		 * Constructor.
		 */
		public function Moveable() 
		{
			position = new Point(this.x, this.y); // set the position as the entity's x,y properties
			velocity = new Point(); // set intial velocity to zero
		}
		
		/**
		 * getCurrentType finds out what path the player is standing on,
		 * and returns the value of that path (uint) that will be used in
		 * e.g. pathMaxVel[] array 
		 */
		
		 //BUG got scarry bug right here, not reproduceable
		 // use a throw statement?
		public function getCurrentPath():uint
		{
			var e:Entity, type:String, pathType:uint;
			e = collideTypes(pathCollideType, x, y);
			
			//trace("collision type: " + e.type);
			
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
			default:
				pathType = 3; // no path
				
			}
			//trace("pathType: " + pathType);
			return pathType;
		}
		
		
		
		
		/**
		 * Moves the entity by the specified amount horizontally and vertically.
		 */
		
		
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
		private var _moveX:Number = 0;
		private var _moveY:Number = 0;
	}
}