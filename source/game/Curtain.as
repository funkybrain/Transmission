package game 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	import net.flashpunk.Entity;
	import net.flashpunk.Graphic;
	import net.flashpunk.graphics.Canvas;
	import net.flashpunk.graphics.Image;
	import net.flashpunk.Tween;
	import net.flashpunk.tweens.misc.NumTween;
	import net.flashpunk.utils.Draw;
	
	/**
	 * Class is used to draw a blind on the main game window 
	 */
		
	public class Curtain extends Entity
	{

		 /**
		 * Textures
		 */
		
		 /**
		 * Class properties
		 */
		 
		private var _fadeInMask:Image;
		private var _fadeInTween:NumTween; 
		private var _fadeInAlpha:Number;
		private var _w:int;
		private var _h:int;
		private var _rect:Rectangle;
		
		public function Curtain(w:int, h:int) 
		{
			this._w = w;
			this._h = h;
			
			// set at screen origin
			this.x = 0;
			this.y = 0;

			_rect = new Rectangle(0, 0, _w, _h);
			_fadeInMask = Image.createRect(_w, _h, 0x000000);
			
			// use 32-bit RGB color value
			// (could use 32-bit ARGB color value, might clash with alpha)
			//_fadeInMask.fill(_rect, 0x000000, 0.8);
			
			graphic = _fadeInMask;
			
			// must be on top of everything
			layer = 0;
			
			// tween the alpha
			_fadeInTween = new NumTween()
			_fadeInTween.tween(1, 0, 5);
			addTween(_fadeInTween);
			_fadeInTween.start();
		}
		
		override public function update():void 
		{
			super.update();
			
			//trace(_fadeInTween.value);
			
			_fadeInMask.alpha = _fadeInTween.value;
			
			if (_fadeInTween.value == 0) 
			{
				//removeTween(_fadeInTween);
			}
	
	
		}
		
		
	}

}