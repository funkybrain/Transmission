package punk.core 
{
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	/**
	 * A special BitmapData class that can contain multiple sprite images and other useful rendering information.
	 * @see FP#getSprite
	 * @see punk.Actor
	 */
	public class Spritemap extends BitmapData
	{
		/**
		 * The sprite's image width.
		 */
		public var imageW:int;
		
		/**
		 * The sprite's image height.
		 */
		public var imageH:int;
		
		/**
		 * How many subimages the sprite has.
		 */
		public var number:int;
		
		/**
		 * The x-origin of the sprite.
		 */
		public var originX:int;
		
		/**
		 * The y-origin of the sprite
		 */
		public var originY:int;
		
		/**
		 * It is recommended that you create Spritemaps with the FP.getSprite() function rather than calling this.
		 * @param	width		The width of the entire Spritemap.
		 * @param	height		The height of the entire Spritemap.
		 * @param	imageWidth	The width of the sprite's images.
		 * @param	imageHeight	The height of the sprite's images.
		 * @param	imageNum	How many images are in the sprite.
		 * @param	originX		The x-origin of the sprite, determines the offset position when drawing it.
		 * @param	originY		The y-origin of the sprite, determines the offset position when drawing it.
		 * @see FP#getSprite()
		 */
		public function Spritemap(width:int, height:int, imageWidth:int = 0, imageHeight:int = 0, imageNum:int = 1, originX:int = 0, originY:int = 0) 
		{
			super(width, height, true, 0);
			imageW = imageWidth > 0 ? imageWidth : width;
			imageH = imageHeight > 0 ? imageHeight : height;
			imageCX = imageW >> 1;
			imageCY = imageH >> 1;
			imageR = width;
			imageB = height;
			number = imageNum;
			this.originX = originX;
			this.originY = originY;
		}
		
		/**
		 * Returns a rectangle corresponding to the specific image's position in the Spritemap.
		 * @param	image	A specific image of the sprite.
		 * @param	flipX	If you want the rect for the x-flipped image.
		 * @param	flipY	If you want the rect for the y-flipped image.
		 */
		public function getRect(image:int = 0, flipX:Boolean = false, flipY:Boolean = false):Rectangle
		{
			_rect.x = flipX ? imageR - image * imageW : image * imageW;
			_rect.y = flipY ? imageB : 0;
			_rect.width = imageW;
			_rect.height = imageH;
			return _rect;
		}
		
		/**
		 * Returns the specific image of the Spritemap as a new BitmapData.
		 * @param	image	A specific image of the sprite.
		 * @param	flipX	If you want the image for the x-flipped image.
		 * @param	flipY	If you want the image for the y-flipped image.
		 */
		public function getImage(image:int = 0, flipX:Boolean = false, flipY:Boolean = false):BitmapData
		{
			var data:BitmapData = new BitmapData(imageW, imageH, true, 0);
			image %= number;
			_rect.x = flipX ? imageR - image * imageW : image * imageW;
			_rect.y = flipY ? imageB : 0;
			_rect.width = imageW;
			_rect.height = imageH;
			data.copyPixels(this, _rect, _zero);
			return data;
		}
		
		// image information
		/** @private */ public var imageR:int;
		/** @private */ public var imageB:int;
		/** @private */ public var imageCX:int;
		/** @private */ public var imageCY:int;
		/** @private */ public var flippedX:Boolean;
		/** @private */ public var flippedY:Boolean;
		
		// global objects
		private var _rect:Rectangle = FP.rect;
		private var _zero:Point = FP.zero;
	}
}