package game 
{
	import flash.display.BitmapData;
	import net.flashpunk.Entity;
	import net.flashpunk.FP;
	import net.flashpunk.graphics.Backdrop;
	import net.flashpunk.graphics.Graphiclist;
	import net.flashpunk.graphics.Image;
	
	/**
	 * Entity class for displaying the background.
	 */
	public class Background extends Entity
	{
		/**
		 * Embedded background graphic.
		 */
		[Embed(source = '../../assets/backgroundSprite.png')] private static const BACKGROUND:Class;
		[Embed(source = '../../assets/spriteBackgroundOne.png')] private static const BACKGROUND_1:Class;
		[Embed(source = '../../assets/spriteBackgroundTwo.png')] private static const BACKGROUND_2:Class;
		[Embed(source = '../../assets/spriteBackgroundThree.png')] private static const BACKGROUND_3:Class;
		[Embed(source = '../../assets/spriteBackgroundFour.png')] private static const BACKGROUND_4:Class;
		
		/**
		 * Constructor.
		 */
		public function Background(x:int, y:int, type:uint) 
		{
			// set the background graphic and parallax rates.
			//graphic = new Backdrop(BACKGROUND, false, false);
			
			switch (type) 
			{
				case 0:
					graphic = new Image(BACKGROUND);
					break;
				case 1:
					graphic = new Image(BACKGROUND_1);
					break;
				case 2:
					graphic = new Image(BACKGROUND_2);
					break;
				case 3:
					graphic = new Image(BACKGROUND_3);
					break;
				case 4:
					graphic = new Image(BACKGROUND_4);
					break;
			}
			
			this.x = x;
			this.y = y;
			
			//graphic.scrollX = .5;
			//graphic.scrollY = .5;
			
			// put it on layer 100, so it appears behind other entities.
			layer = 100;
		}
		
		/**
		 * Updates the background, makes it scroll.
		 */
		override public function update():void 
		{
			//x -= FP.elapsed * 20;
			//y -= FP.elapsed * 10;
		}
	}
}