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
		[Embed(source = '../../assets/spritesheetAvatarFils.png')] private const ROBOT_CHILD:Class;
		public var robotChild:Spritemap = new Spritemap(ROBOT_CHILD, 30, 30);
		
		[Embed(source = '../../assets/spritesheetAvatar.png')] private const ROBOT_FATHER:Class;
		public var robotFather:Spritemap = new Spritemap(ROBOT_FATHER, 30, 30);
		
		/**
		 * Animation properties.
		 */
		public var frames:Array;
		
		/**
		 * Robot state
		 */
		public var state:String;
		
		public function Robot(_x:Number, _y:Number, _state:String) 
		{
			this.x = _x;
			this.y = _y;
			
			type = "robot";
			state = _state;
			frames = new Array( 0, 1, 2, 3 );
			// set the Entity's graphic property to a Spritemap object
			setSprite();
		}
		
		public function setSprite():void
		{
			if (state=="robotchild") 
			{
				graphic = robotChild;
				robotChild.add("walk", frames, 5, true);
			} else {
				graphic = robotFather;
				robotFather.add("walk", frames, 5, true);
			}
			
			
			
			
		}
		
		
	}

}