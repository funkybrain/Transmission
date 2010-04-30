package punk
{
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.Matrix;
	import flash.display.BitmapData;
	import punk.core.Entity;
	import punk.core.Screen;
	import punk.core.Spritemap;
	
	/**
	 * A game Entity able to display and switch between animated sprites.
	 * @see punk.Acrobat
	 * @see punk.core.Spritemap
	 */
	public class Actor extends Entity
	{
		/**
		 * The Spritemap to display at this Actor's position. Get Spritemaps with the FP.getSprite() function.
		 * @see FP#getSprite()
		 */
		public function get sprite():Spritemap
		{
			return _sprite;
		}
		public function set sprite(value:Spritemap):void
		{
			if (!_sprite && !width && !height)
			{
				width = value.width;
				height = value.height;
			}
			_sprite = value;
			_image %= _sprite.number;
			_rect.width = _sprite.imageW;
			_rect.height = _sprite.imageH;
		}
		
		/**
		 * The image of the Spritemap that is being displayed.
		 * @see punk.core.Spritemap#number
		 */
		public function get image():int
		{
			return _image;
		}
		public function set image(value:int):void
		{
			_image = value % _sprite.number;
		}
		
		/**
		 * The frame-delay for each image of the Spritemap animation. Increase to slow animation, set to 0 to not animate.
		 */
		public var delay:int = 1;
		
		/**
		 * If the sprite should display x-flipped. The sprite must have pre-x-flipped images for this to work.
		 * @see FP#getSprite()
		 */
		public var flipX:Boolean = false;
		
		/**
		 * If the sprite should display y-flipped. The sprite must have pre-y-flipped images for this to work.
		 * @see FP#getSprite()
		 */
		public var flipY:Boolean = false;
		
		/**
		 * If the animation should start over when it ends (true) or stop and set delay to 0 on the last frame (false).
		 */
		public var loop:Boolean = true;
		
		/**
		 * An optional function to have called when the animation ends or loops.
		 */
		public var anim:Function = null;
		
		/**
		 * Constructor.
		 */
		public function Actor() 
		{
			
		}
		
		/**
		 * If you override render, you can update the animation cycle by calling this every frame, so your Actor animates as it normally would.
		 * @param	totalFrames		How many frames your animation has, so it knows when to loop/stop.
		 */
		public function updateImage(totalFrames:int = 0):void
		{
			// animation cycle
			if (!delay) return;
			_count ++;
			if (_count >= delay)
			{
				_count = 0;
				_image ++;
				if (_image == totalFrames)
				{
					_image = loop ? 0 : _image - 1;
					if (anim !== null) anim();
				}
			}
		}
		
		/**
		 * Actor renders its sprite to the screen at the correct location. If you override
		 * this, the sprite will not be drawn unless you call super.render() in the override.
		 */
		override public function render():void
		{
			if (!_sprite) return;
			
			// get the image & drawing position
			_rect.x = flipX ? _sprite.imageR - _image * _sprite.imageW : _image * _sprite.imageW;
			_rect.y = flipY ? _sprite.imageB : 0;
			_point.x = x - _sprite.originX - FP.camera.x;
			_point.y = y - _sprite.originY - FP.camera.y;
			
			// draw onto the screen
			FP.screen.copyPixels(sprite, _rect, _point);
			
			// animation cycle
			if (!delay) return;
			_count ++;
			if (_count >= delay)
			{
				_count = 0;
				_image ++;
				if (_image == _sprite.number)
				{
					_image = loop ? 0 : _image - 1;
					if (anim !== null) anim();
				}
			}
		}
		
		// sprite and animation
		/** @private */ internal var _image:int = 0;
		/** @private */ internal var _count:int = 0;
		/** @private */ internal var _sprite:Spritemap = null;
		/** @private */ internal var _rect:Rectangle = new Rectangle();
		
		// global objects
		/** @private */ internal var _point:Point = FP.point;
		/** @private */ internal var _zero:Point = FP.zero;
		/** @private */ internal var _matrix:Matrix = FP.matrix;
	}
}