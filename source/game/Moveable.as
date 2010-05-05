package game 
{
	import net.flashpunk.Entity;
	
	/**
	 * Base class for moving Entities to handle collision.
	 */
	public class Moveable extends Entity
	{
		/**
		 * Entity -type- to consider solid when colliding.
		 */
		public var pathArray:Array = new Array("red", "green", "blue");
		
		/**
		 * Constructor.
		 */
		public function Moveable() 
		{
			
		}
		
		/**
		 * Moves the entity by the specified amount horizontally and vertically.
		 */
		public function move(moveX:Number = 0, moveY:Number = 0):void
		{
			// movement counters
			_moveX += moveX;
			_moveY += moveY;
			moveX = Math.round(_moveX);
			moveY = Math.round(_moveY);
			_moveX -= moveX;
			_moveY -= moveY;
			
			// movement vars
			var sign:int, e:Entity;
			
			// horizontal
			if (moveX != 0)
			{
				sign = moveX > 0 ? 1 : -1;
				while (moveX != 0)
				{
					moveX -= sign;
					if ((e = collideTypes(pathArray, x + sign, y)))
					{
						collideX(e);
						x += sign;
						trace(e.type);
						
					}
					else {						
						moveX = 0;
					}
				}
			}
			
			// vertical
			if (moveY != 0)
			{
				sign = moveY > 0 ? 1 : -1;
				while (moveY != 0)
				{
					moveY -= sign;
					if ((e = collideTypes(pathArray, x, y + sign)))
					{
						collideY(e);
						y += sign;
					}
					else {
						moveY = 0;						
					}
				}
			}
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
		private var _moveX:Number = 0;
		private var _moveY:Number = 0;
	}
}