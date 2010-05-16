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
		public var robotSprite:Spritemap = new Spritemap(PLAYER, 30, 30);
		
		/**
		 * Animation properties.
		 */
		public var frames:Array;
		
		public function Robot(_x:Number, _y:Number) 
		{
			this.x = _x;
			this.y = _y;
			
			type = "robot";
			
			// set the Entity's graphic property to a Spritemap object
			graphic = robotSprite;
			frames = new Array( 0, 1, 2, 3 );
			robotSprite.add("walk", frames, 5, true);
		}
		
		
	}

}