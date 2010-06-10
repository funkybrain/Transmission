package game 
{
	import adobe.utils.CustomActions;
	import flash.display.BitmapData;
	import flash.display.Bitmap;
	import flash.geom.Rectangle;
	import net.flashpunk.Entity;
	import net.flashpunk.graphics.Backdrop;
	import net.flashpunk.graphics.Canvas;
	import net.flashpunk.utils.Draw;
	import net.flashpunk.FP;
	import flash.geom.Point;
	
	
	public class Papyrus extends Entity
	{
		
		[Embed(source='../../assets/texturePapyrus.png')] private static const TEXTURE:Class;
		//public static const TEXTURE : Class;
		//private static const _bitmap : BitmapData = new TEXTURE().bitmapData;
		
		/*[Embed(source='../../assets/texturePapyrus_alpha.png')]
		public static const ALPHA : Class;
		private static const _alpha2 : BitmapData = new ALPHA().bitmapData;*/
		
		private var _canvas:Canvas;
		public var rect:Rectangle;
		private var _alpha:BitmapData = new BitmapData(480, 480, true, 0x00FFFFFF);
		private var _bitmap:BitmapData;
		
		private var _width:Number; // the width of the rectangle where the texture will be drawn
		private var _height:Number;
		
		public function Papyrus(x:Number, y: Number, w:Number, h:Number) 
		{
			this.x = x;
			this.y = y;
			_width = w;
			_height = h;
			
			layer = 2;
			
			// rect area of the CANVAS that will be filled with thexture
			rect = new Rectangle(0, 0, 0, _height);
			
			_bitmap = FP.getBitmap(TEXTURE);
			
			var sq:Rectangle = new Rectangle(0, 0, 480, 480);
			var pt:Point = new Point(0, 0);
			var mult:uint = 0; // 0%
			var a:uint = 0xe6; //
			_bitmap.merge(_alpha, sq, pt, mult, mult, mult, a);

			//_bitmap:BitmapData = new TEXTURE().bitmapData;
			
			
			//trace("transparent: " + _bitmap.transparent);
			
			//trace("rect " + rect);
			//trace("bmp rect: " + _bitmap.rect);
			
			// width is read-only, so make sure the canvas is long enough to display all the text
			_canvas = new Canvas(4000, 480);
			
			graphic = _canvas;
			
			//trace("visible: " + _canvas.visible);
			//trace("canvas width : " + _canvas.width);
			//trace("canvas x: " + _canvas.x);
			//trace("papyrus x: " + x);			
		}
		
		// getters and setters
		public function set rectWidth(value:Number):void { _width = value;}
		public function get rectWidth():Number { return _width;	}
		
		override public function update():void 
		{
			rect.width = _width;
			//trace("rect width: " + rect.width);
			
			super.update();
		}
		
		override public function render():void 
		{				
			_canvas.fillTexture(rect, _bitmap);
			super.render();
		}
		
	}

}