package punk
{
	import flash.display.BitmapData;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.Matrix;
	import punk.core.Spritemap;
	
	/**
	 * A special Actor class that can render its sprite with alpha, scale, and rotation values.
	 * @see punk.core.Spritemap
	 */
	public class Acrobat extends Actor
	{
		/**
		 * The alpha blending factor.
		 */
		public var alpha:Number = 1;
		
		/**
		 * Set this to draw the sprite in a single blank colour. Set to 0 to draw normally.
		 */
		public var color:uint = 0;
		
		/**
		 * The x-scale of the sprite. So when set to 2, the sprite will be twice as wide.
		 */
		public var scaleX:Number = 1;
		
		/**
		 * The y-scale of the sprite. So when set to 2, the sprite will be twice as tall.
		 */
		public var scaleY:Number = 1;
		
		/**
		 * The angle of rotation in degrees. Set to 0 for no rotation, increase to rotate counter-clockwise.
		 */
		public var angle:Number = 0;
		
		/**
		 * If it should pivot the sprite around the center of the sprite (true) or around the sprite's origin (false).
		 */
		public var center:Boolean = false;
		
		/**
		 * Constructor.
		 */
		public function Acrobat() 
		{
			
		}
		
		/**
		 * Acrobat renders its sprite to the screen at the correct location, and uses a
		 * transformation matrix to scale and rotate it.If you override this, the sprite
		 * will not be drawn unless you call super.render() in the override.
		 */
		override public function render():void
		{
			if (!_sprite) return;
			
			// check if the buffer needs updated
			if (_update || _image !== _img || flipX !== _flipX || flipY !== _flipY || alpha !== _alpha)
			{
				// get the image
				_rect.x = flipX ? _sprite.imageR - _image * _sprite.imageW : _image * _sprite.imageW;
				_rect.y = flipY ? _sprite.imageB : 0;
				
				// update the buffer
				_update = false;
				_img = _image;
				_flipX = flipX;
				_flipY = flipY;
				_alpha = _color.alphaMultiplier = alpha;
				_buffer.copyPixels(_sprite, _rect, _zero);
				if (_alpha < 1 || color)
				{
					if (color)
					{
						_color.redMultiplier = _color.greenMultiplier = _color.blueMultiplier = 1;
						_color.redOffset = _color.greenOffset = _color.blueOffset = _color.alphaOffset = 0;
						_color.color = color;
					}
					_buffer.colorTransform(_buffer.rect, _color);
				}
			}
			
			// draw without transformation
			if (angle == 0 && scaleX == 1 && scaleY == 1)
			{
				// get the drawing position
				_point.x = x - _sprite.originX - FP.camera.x;
				_point.y = y - _sprite.originY - FP.camera.y;
				
				// draw the buffer to the screen
				FP.screen.copyPixels(_buffer, _bufferRect, _point);
				
				// animation cycle
				if (!delay) return;
				_count ++;
				if (_count >= delay)
				{
					_count = 0;
					_image ++;
					if (_image == _sprite.number) _image = loop ? 0 : _image - 1;
					else if (anim !== null && _image == _sprite.number - 1) anim();
				}
				return;
			}
			
			// transformation matrix
			_matrix.a = scaleX;
			_matrix.d = scaleY;
			_matrix.b = _matrix.c = 0;
			if (center)
			{
				_matrix.tx = -_sprite.imageCX * scaleX;
				_matrix.ty = -_sprite.imageCY * scaleY;
				if (angle != 0) _matrix.rotate(angle * _DEG);
				_matrix.tx += x - FP.camera.x - _sprite.originX + _sprite.imageCX;
				_matrix.ty += y - FP.camera.y - _sprite.originY + _sprite.imageCY;
			}
			else
			{
				_matrix.tx = -_sprite.originX * scaleX;
				_matrix.ty = -_sprite.originY * scaleY;
				if (angle != 0) _matrix.rotate(angle * _DEG);
				_matrix.tx += x - FP.camera.x;
				_matrix.ty += y - FP.camera.y;
			}
			
			// draw buffer transformed
			FP.screen.draw(_buffer, _matrix);
			
			// animation cycle
			if (!delay) return;
			_count ++;
			if (_count >= delay)
			{
				_count = 0;
				_image ++;
				if (_image == _sprite.number) _image = loop ? 0 : _image - 1;
				else if (anim !== null && _image == _sprite.number - 1) anim();
			}
		}
		
		/**
		 * @inhritDoc
		 */
		override public function get sprite():Spritemap
		{
			return _sprite;
		}
		override public function set sprite(value:Spritemap):void
		{
			super.sprite = value;
			if (!_buffer || _sprite.imageW > _buffer.width || _sprite.imageH > _buffer.height)
			{
				_buffer = new BitmapData(_sprite.imageW, _sprite.imageH, true, 0);
				_bufferRect = _buffer.rect;
			}
			else _buffer.fillRect(_buffer.rect, 0);
			_update = true;
			// TODO: instead of keeping the _buffer, track a different buffer for each different sprite
		}
		
		// rad-to-deg conversion
		private const _DEG:Number = -Math.PI / 180;
		
		// sprite rendering
		private var _color:ColorTransform = new ColorTransform();
		private var _buffer:BitmapData;
		private var _bufferRect:Rectangle;
		private var _update:Boolean = true;
		private var _img:int;
		private var _flipX:Boolean;
		private var _flipY:Boolean;
		private var _alpha:Number;
	}
}