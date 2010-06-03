package game 
{
	import net.flashpunk.Entity;
	import net.flashpunk.graphics.Spritemap;
	import net.flashpunk.graphics.Image;
	import net.flashpunk.tweens.misc.VarTween;
	import net.flashpunk.utils.Ease;
	
	/**
	 * This class is used as
	 * a background animation factory!
	 */
	
	public class Animation extends Entity
	{
		/**
		 * Background graphics.
		 */
		[Embed(source = '../../assets/spriteSheetAnim_Man.png')] private const MAN:Class;
		public var man:Spritemap = new Spritemap(MAN, 238, 480);
		
		[Embed(source = '../../assets/spriteSheetAnim_Rouage.png')] private const ROUAGE:Class;
		public var rouage:Spritemap = new Spritemap(ROUAGE, 300, 300);
		
		[Embed(source = '../../assets/spriteSheetAnim_Prison.png')] private const PRISON:Class;
		public var prison:Spritemap = new Spritemap(PRISON, 270, 210);
		
		[Embed(source='../../assets/spriteSheetAnim_Crash.png')] private const CRASH:Class;
		public var crash:Spritemap = new Spritemap(CRASH, 450, 200);
		
		/**
		 * Animation properties.
		 */
		private var _frames:Array;
		public	var spriteName:Spritemap;
		public var triggerDistance:int = 50; // will trigger animation at 50 px distance
		public var animType:uint; // 0=one shot, 1=looping
		
		/**
		 * Constructor.
		 * @param	x		x position of the entity
		 * @param	y		y position of the entity
		 * @param	name	animation to play
		 */
		public function Animation(x:int, y:int, name:String, type:uint) 
		{
			this.x = x;
			this.y = y;
			this.animType = type;
			
			// set entity depth behind path but above background
			layer = 50;
			

			
			// set the entity's graphic property to a Spritemap object
			// and create an animation
			addAnimation(name);
		}
		
		private function addAnimation(name:String):void
		{

						
			switch (name)
			{
			case "man":
				spriteName = man;
				_frames = new Array( 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10);
				break;
			case "rouage":
				spriteName = rouage;
				_frames = new Array( 0, 1, 2, 3);
				break;
			case "prison":
				spriteName = prison;
				_frames = new Array( 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15);
				break;
			case "crash":
				spriteName = crash;
				_frames = new Array( 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13);
				break;
			default:
				break; // no animation?
				
			}
			
			graphic = spriteName;
			
			//graphic.scrollX = .5;
			//graphic.scrollY = .5;
				
			spriteName.add("loop", _frames, 24, true); // will loop
			spriteName.add("no_loop", _frames, 24, false); // won't loop
		}
		
		public function playLooping():void
		{
			spriteName.play("loop");
		}
		
		public function playOnce():void
		{
			spriteName.play("no_loop");
		}
		
	}

}