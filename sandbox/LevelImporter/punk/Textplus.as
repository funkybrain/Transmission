package punk 
{
	import flash.display.BitmapData;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	
	/**
	 * An extended version of the Text class that allows you to display your text rotated, scaled, or with an alpha value.
	 * @see punk.Text;
	 */
	public class Textplus extends Text
	{
		/**
		 * The x-scale of the text. So when set to 2, the text will render twice as wide.
		 */
		public var scaleX:Number = 1;
		
		/**
		 * The y-scale of the text. So when set to 2, the text will render twice as tall.
		 */
		public var scaleY:Number = 1;
		
		/**
		 * The angle of rotation in degrees. Set to 0 for no rotation, increase to rotate counter-clockwise.
		 */
		public var angle:Number = 0;
		
		/**
		 * You can set the string for the TextPlus object and its starting position in the contructor.
		 * @param	str	The string that the TextPlus object should display.
		 * @param	x	The x-position to place it.
		 * @param	y	The y-position to place it.
		 */
		public function Textplus(str:String = "", x:int = 0, y:int = 0) 
		{
			super(str, x, y);
		}
		
		/**
		 * The alpha blending factor.
		 */
		public function get alpha():Number
		{
			return _color.alphaMultiplier;
		}
		public function set alpha(value:Number):void
		{
			_color.alphaMultiplier = value;
			prepare();
		}
		
		/**
		 * TextPlus will render its string to the screen at the correct position, transforming it accordingly.
		 */
		override public function render():void 
		{
			// draw without transformation
			if (angle == 0 && scaleX == 1 && scaleY == 1)
			{
				// get the drawing position
				_point.x = x - originX - FP.camera.x;
				_point.y = y - originY - FP.camera.y;
				
				// draw the buffer to the screen
				FP.screen.copyPixels(_data, _rect, _point);
				return;
			}
			
			// transformation matrix
			_matrix.a = scaleX;
			_matrix.d = scaleY;
			_matrix.b = _matrix.c = 0;
			_matrix.tx = -originX * scaleX;
			_matrix.ty = -originY * scaleY;
			if (angle != 0) _matrix.rotate(angle * _DEG);
			_matrix.tx += x - FP.camera.x;
			_matrix.ty += y - FP.camera.y;
			
			// draw buffer transformed
			FP.screen.draw(_data, _matrix);
		}
		
		/** 
		 * @private prepares the display bitmap after formatting the text, and applies colorTransform to it
		 */
		override internal function prepare():void 
		{
			super.prepare();
			if (_color.alphaMultiplier < 1)
			{
				_color.alphaMultiplier = alpha;
				_data.colorTransform(_rect, _color);
			}
		}
		
		// rad-to-deg conversion
		private const _DEG:Number = -Math.PI / 180;
		
		// update buffer
		private var _update:Boolean = true;
		
		// global objects
		private var _matrix:Matrix = FP.matrix;
		private var _color:ColorTransform = new ColorTransform();
	}
}