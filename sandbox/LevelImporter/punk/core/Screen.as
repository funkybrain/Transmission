package punk.core
{
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import punk.util.Input;
	
	/**
	 * The main screen BitmapData canvas. All Actors, Text, Backdrop, etc. draw to FP.screen.
	 * @see FP#screen
	 */
	public class Screen extends BitmapData
	{
		/**
		 * The background color of the screen. Every frame the screen will refresh and clear itself with this color.
		 */
		public var color:uint = 0x202020;
		
		/**
		 * The scale of the screen.
		 */
		public var scale:Number = 1;
			
		/**
		 * This object is automatically created by Engine, and assigned to FP.screen, when the game starts.
		 * @param	width	The unscaled width of the screen.
		 * @param	height	The unscaled height of the screen.
		 * @param	color	The background color of the screen.
		 * @param	scale	The scale of the screen.
		 */
		public function Screen(width:int, height:int, color:uint = 0x202020, scale:int = 1)
		{
			super(width, height, false, color);
			this.color = color;
			this.scale = scale;
		}
			
		/**
		 * Draws a rectangle over the entire screen.
		 * @param	color	The color to draw.
		 * @param	alpha	The alpha blending factor to draw.
		 */
		public function drawClear(color:uint = 0x000000, alpha:Number = 1):void
		{
			if (alpha >= 1)
			{
				fillRect(_rect, color);
				return;
			}
			var g:Graphics = FP.sprite.graphics;
			g.clear();
			g.beginFill(color, alpha);
			g.drawRect(0, 0, width, height);
			g.endFill();
			draw(FP.sprite);
		}
		
		/**
		 * The x-position of the mouse on the Screen.
		 * @see punk.util.Input#mouseX
		 * @see punk.util.Camera#mouseX
		 * @see punk.core.World#mouseX
		 */
		public function get mouseX():Number
		{
			return Input.mouseX;
		}
		
		/**
		 * The x-position of the mouse on the Screen.
		 * @see punk.util.Input#mouseY
		 * @see punk.util.Camera#mouseY
		 * @see punk.core.World#mouseY
		 */
		public function get mouseY():Number
		{
			return Input.mouseY;
		}
		
		// global objects
		/** @private */ internal var _rect:Rectangle = FP.rect;
		private var _point:Point = FP.point;
		private var _stage:Stage = FP.stage;
		private var _color:ColorTransform = FP.color;
		private var _zero:Point = FP.zero;
	}
}