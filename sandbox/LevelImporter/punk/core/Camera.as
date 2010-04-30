package punk.core 
{
	import flash.geom.Point;
	import punk.util.Input;
	
	/**
	 * The Camera determines the offset drawing position of all Entities in the World. Its x and y values represent
	 * the top-left position of the Screen in the World. (Eg. as x increases, Entities are drawn more to the left.)
	 * @see FP#camera
	 */
	public class Camera
	{
		/**
		 * Camera's x-position.
		 */
		public var x:Number = 0;
		
		/**
		 * Camera's y-position.
		 */
		public var y:Number = 0;
		
		/**
		 * Camera's x-origin when using movement functions.
		 */
		public var originX:Number = 0;
		
		/**
		 * Camera's y-origin when using movement functions.
		 */
		public var originY:Number = 0;
		
		/**
		 * Constructor.
		 */
		public function Camera() 
		{
			
		}
		
		/**
		 * Places the Camera at the position, keeping it within its movement bounds.
		 * @param	x	The x-position to place it.
		 * @param	y	The y-position to place it.
		 */
		public function moveTo(x:Number = 0, y:Number = 0):void
		{
			this.x = x - originX;
			this.y = y - originY;
			clampInBounds();
		}
		
		/**
		 * Takes a step towards the target position, keeping it within its movement bounds.
		 * @param	x		The target x-position.
		 * @param	y		The target y-position.
		 * @param	speed	How many pixels to move.
		 */
		public function stepTowards(x:Number, y:Number, speed:Number):void
		{
			_point.x = x - originX - this.x;
			_point.y = y - originY - this.y;
			if (_point.length < speed)
			{
				this.x = x - originX;
				this.y = y - originY;
				clampInBounds();
				return;
			}
			_point.normalize(speed);
			this.x += _point.x;
			this.y += _point.y;
			clampInBounds();
		}
		
		/**
		 * Sets the movement bounds of the Camera.
		 * @param	left	The left-edge of the Camera bounds.
		 * @param	top		The top-edge of the Camera bounds.
		 * @param	right	The right-edge of the Camera bounds.
		 * @param	bottom	The bottom-edge of the Camera bounds.
		 */
		public function setBounds(left:int, top:int, right:int, bottom:int):void
		{
			_minX = left;
			_minY = top;
			_maxX = right - _width;
			_maxY = bottom - _height;
			clampInBounds();
		}
		
		/**
		 * Sets the origin of the Camera, keeping it within its movement bounds.
		 * @param	originX
		 * @param	originY
		 */
		public function setOrigin(originX:Number = 0, originY:Number = 0):void
		{
			x += this.originX - originX;
			y += this.originY - originY;
			this.originX = originX;
			this.originY = originY;
			clampInBounds();
		}
		
		/**
		 * Centers the origin of the Camera, keeping it within its movement bounds.
		 */
		public function centerOrigin():void
		{
			x += originX - _width / 2;
			y += originY - _height / 2;
			originX = _width / 2;
			originY = _height / 2;
			clampInBounds();
		}
		
		/**
		 * Clamps the Camera within its movement bounds.
		 */
		public function clampInBounds():void
		{
			if (x < _minX) x = _minX;
			if (y < _minY) y = _minY;
			if (x > _maxX) x = _maxX;
			if (y > _maxY) y = _maxY;
		}
		
		/**
		 * The x-position of the mouse on the Screen. The same value as Screen's mouseX property.
		 * @see punk.core.Screen#mouseX
		 * @see punk.util.Input#mouseX
		 * @see punk.core.World#mouseX
		 */
		public function get mouseX():Number
		{
			return Input.mouseX;
		}
		
		/**
		 * The y-position of the mouse on the Screen. The same value as Screen's mouseY property.
		 * @see punk.core.Screen#mouseY
		 * @see punk.util.Input#mouseY
		 * @see punk.core.World#mouseY
		 */
		public function get mouseY():Number
		{
			return Input.mouseY;
		}
		
		/**
		 * Checks if the point in the World is within the Camera's view.
		 * @param	x	The x-position.
		 * @param	y	The y-position.
		 */
		public function collidePoint(x:int, y:int):Boolean
		{
			return x >= this.x
				&& y >= this.y
				&& x < this.x + this._width
				&& y < this.y + this._width;
		}
		
		/**
		 * Checks if the rectangle in the World is within the Camera's view.
		 * @param	x
		 * @param	y
		 * @param	width
		 * @param	height
		 * @return
		 */
		public function collideRect(x:int, y:int, width:int, height:int):Boolean
		{
			return x + _width > this.x
				&& y + _height > this.y
				&& x < this.x + this._width
				&& y < this.y + this._height;
		}
		
		// the camera size
		/** @private */ protected var _width:int = FP.screen.width;
		/** @private */ protected var _height:int = FP.screen.height;
		
		// the boundaries for the Camera's movement
		/** @private */ protected var _minX:int = int.MIN_VALUE;
		/** @private */ protected var _minY:int = int.MIN_VALUE;
		/** @private */ protected var _maxX:int = int.MAX_VALUE;
		/** @private */ protected var _maxY:int = int.MAX_VALUE;
		
		// global objects
		private var _point:Point = FP.point;
	}
}