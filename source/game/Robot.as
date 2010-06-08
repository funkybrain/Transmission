package game 
{
	import flash.geom.Point;
	import net.flashpunk.Entity;
	import net.flashpunk.graphics.*;
	
	/**
	 * Robot class is controlled by AI 
	 */
	
	public class Robot extends Moveable
	{
		/**
		 * Player graphic.
		 */
		[Embed(source = '../../assets/spritesheetChild.png')] private const ROBOT_CHILD:Class;
		public var robotChild:Spritemap = new Spritemap(ROBOT_CHILD, 30, 30);
		
		[Embed(source = '../../assets/spritesheetFather.png')] private const ROBOT_FATHER:Class;
		public var robotFather:Spritemap = new Spritemap(ROBOT_FATHER, 30, 30);
		
		/**
		 * Animation properties.
		 */
		public var frames:Array;
		
		/**
		 * Robot properties
		 */
		public var state:String;
		
		/**
		 * Movement properties
		 */
		private var compass:Vector.<Point> = new Vector.<Point>();
		 
		public function Robot(_x:Number, _y:Number, _state:String) 
		{
			this.x = _x;
			this.y = _y;
			
			position.x = x;
			position.y = y;
			
			// offset graphics so that they are centered around entity's origin
			robotChild.x = -15;
			robotChild.y = -15;
			robotChild.originX = 15;
			robotChild.originY = 15;
			
			
			robotFather.x = -15;
			robotFather.y = -15;
			
			type = "robot";
			state = _state;
			frames = new Array( 0, 1, 2, 3 );
			
			// set the Entity's graphic property to a Spritemap object
			setSprite();
			
			// set compass values
			compass[0] = new Point(0, -1); // up
			compass[1] = new Point(1, 0); // right
			compass[2] = new Point(0, 1); // down
			compass[3] = new Point(-1, 0); // left
			
		}
		
		public function setSprite():void
		{
			if (state=="robotchild") 
			{
				graphic = robotChild;
				robotChild.add("walk", frames, 12, true);
				robotChild.scale = 0.5;
			} else {
				graphic = robotFather;
				robotFather.add("walk", frames, 12, true);
			}
		}
		
		public function walk(path_:uint):void
		{
			var step:int = 1; // number of pixels father moves each frame
			var e:Entity;
			var next_pos:Point;
			
			for (var i:int = 0; i < 4; i++) 
			{
				e = collideTypes(pathCollideType, x, y);
				if (e) 
				{
					//TODO go around the compass to miove father
				}
			}
		}
		
		
	}

}