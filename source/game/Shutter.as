package game 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	import net.flashpunk.Entity;
	import net.flashpunk.Graphic;
	import net.flashpunk.graphics.Canvas;
	import net.flashpunk.graphics.Image;
	import net.flashpunk.utils.Draw;
	
	/**
	 * Class is used to draw a blind on the main game window 
	 */
		
	public class Shutter extends Entity
	{

		 /**
		 * Textures
		 */
		[Embed(source = '../../assets/shutterTexture.png')] private const SHUTTER:Class;
		
		 /**
		 * Class properties
		 */
		 public var hBlind:Image = new Image(SHUTTER);
		 private var _debug:Boolean = false;
		 
		 //private var _rect:Rectangle = new Rectangle(0, 0, 400, 480);
		 
		public function Shutter(x:int=0, y:int=0) 
		{
			this.x = x;
			this.y = y;
			
			graphic = hBlind;
			//graphic.scrollX = .5;
			//graphic.scrollY = .5;
			
			layer = 0;
			
		}
		
		override public function render():void 
		{
			super.render();
			if (_debug) 
			{
				Draw.line(x, y, x, y + 480);
			}
		}
		
		/**
		 * Getter functions.
		 */
		//public function get canvas():Canvas { return _hBlind; }
		
	}

}