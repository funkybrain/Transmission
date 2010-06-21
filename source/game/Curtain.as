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
		 
		protected var _fadeMask:Image;
		protected var _fadeTween:NumTween; 
		protected var _fadeAlpha:Number;
		protected var _w:int;
		protected var _h:int;
		protected var _rect:Rectangle;
		protected var _type:String;
		protected var _time:int;

				
		public var complete:Boolean = false;

		
		public function Curtain(w:int, h:int, model:String, time:int) 
		{
			this._w = w;
			this._h = h;
			this._type = model;
			this._time = time;
			
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
			init();
			
			
		}
		
		protected function init():void
		{
			_fadeTween = new NumTween(_onComplete)
						
			if (_type == "in") 
			{
				// fade in effect
				_fadeTween.tween(1, 0, _time, Ease.circIn);
			}
			else // type = "out"
			{
				// fade out effect
				_fadeTween.tween(0, 1, _time, Ease.circIn);
			}
			
			addTween(_fadeTween);
			_fadeTween.start();
		}
		
		override public function update():void 
		{
			super.update();
			
			_fadeMask.alpha = _fadeTween.value;
			

		}
		
		protected function _onComplete():void
		{
			complete = true;
		}
		
		
	}

}