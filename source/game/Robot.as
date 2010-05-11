package game 
{
	import net.flashpunk.Entity;
	import net.flashpunk.graphics.*;
	
	/**
	 * Robot class is controlled by AI 
	 */
	
	public class Robot extends Entity
	{
		/**
		 * Player graphic.
		 */
		[Embed(source = '../../assets/spritesheetAvatarFils.png')] private const PLAYER:Class;
		public var robot:Spritemap = new Spritemap(PLAYER, 30, 30);
		
		/**
		 * Animation properties.
		 */
		public var frames:Array;
		
		public function Robot(_x:Number, _y:Number) 
		{
			this.x = _x;
			this.y = _y;
			
			// set the Entity's graphic property to a Spritemap object
			graphic = robot;
			frames = new Array( 0, 1, 2, 3 );
			robot.add("walk", frames, 5, true);
		}
		
	}

}