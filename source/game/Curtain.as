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
	import net.flashpunk.utils.Ease;
	
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
		 
		private var _fadeMask:Image;
		private var _fadeTween:NumTween; 
		private var _fadeAlpha:Number;
		private var _w:int;
		private var _h:int;
		private var _rect:Rectangle;
		private var _type:String;

				
		public var complete:Boolean = false;

		
		public function Curtain(w:int, h:int, model:String) 
		{
			this._w = w;
			this._h = h;
			this._type = model;
			
			// set at origin
			this.x = 0;
			this.y = 0;

			_rect = new Rectangle(0, 0, _w, _h);
			_fadeMask = Image.createRect(_w, _h, 0x000000);
			
			// use 32-bit RGB color value
			// (could use 32-bit ARGB color value, might clash with alpha)
			//_fadeInMask.fill(_rect, 0x000000, 0.8);
			
			graphic = _fadeMask;
			
			// must be on top of everything
			layer = Layers.CURTAIN;
			
			
			//intialize curtain
			_init();
			
			
		}
		
		private function _init():void
		{
			_fadeTween = new NumTween(_onComplete)
						
			if (_type == "in") 
			{
				// fade in effect
				_fadeTween.tween(1, 0, 5, Ease.circIn);
			}
			else // type = "out"
			{
				// fade out effect
				_fadeTween.tween(0, 1, 15, Ease.circIn);
			}
			
			addTween(_fadeTween);
			_fadeTween.start();
		}
		
		override public function update():void 
		{
			super.update();
			
			_fadeMask.alpha = _fadeTween.value;
			

		}
		
		private function _onComplete():void
		{
			complete = true;
		}
		
		
	}

}