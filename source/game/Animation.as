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
		
		/**
		 * Animation properties.
		 */
		private var _frames:Array;
		private var _fadeIn:VarTween;
		public	var spriteName:Spritemap;
		
		/**
		 * Constructor.
		 * @param	x		x position of the entity
		 * @param	y		y position of the entity
		 * @param	name	animation to play
		 */
		public function Animation(x:int, y:int, name:String) 
		{
			this.x = x;
			this.y = y;
			
			// set entity depth behind path but abopve background
			layer = 50;
			

			
			// set the entity's graphic property to a Spritemap object
			// and create an animation
			playAnimation(name);
		}
		
		private function playAnimation(name:String):void
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
			default:
				break; // no animation?
				
			}
			
			graphic = spriteName;
			
			graphic.scrollX = .5;
			graphic.scrollY = .5;
			
			//spriteName.alpha = 0.1;
			
			spriteName.add("play", _frames, 10, true); // will loop
			spriteName.play("play");
			
			//fade sprite in
			//fadeIn = new VarTween();
			//addTween(fadeIn);
			//fadeIn.tween(spriteName, "alpha", 1, 4, Ease.backIn);
			//fadeIn.start();
		}
		
	}

}