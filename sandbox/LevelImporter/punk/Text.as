package punk 
{
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import punk.core.Entity;
	
	/**
	 * A game Entity for displaying text on the screen using embedded fonts.
	 * @see punk.Textplus;
	 */
	public class Text extends Entity
	{
		/**
		 * For left-aligned text.
		 */
		public static const LEFT:String = TextFormatAlign.LEFT;
		
		/**
		 * For center-aligned text.
		 */
		public static const CENTER:String = TextFormatAlign.CENTER;
		
		/**
		 * For right-aligned text.
		 */
		public static const RIGHT:String = TextFormatAlign.RIGHT;
		
		/**
		 * The embedded font-family to use.
		 */
		public static var font:String = "Default";
		
		/**
		 * The point-size of the font.
		 */
		public static var size:int = 8;
		
		/**
		 * The color that the text should display.
		 */
		public static var color:uint = 0x000000;
		
		/**
		 * The alignment of the text. If you want a single-line of text to be centered without
		 * Flash player's font rendering blurring it, you can call center() instead, which will
		 * set the Text object's origin to its center.
		 * @see #center()
		 */
		public static var align:String = TextFormatAlign.LEFT;
		
		/**
		 * Use this to set multiple format values in one go.
		 * @param	font	The embedded font-family to use.
		 * @param	size	The point-size of the font.
		 * @param	color	The color that the text should display.
		 * @param	align	The alignment of the text.
		 */
		public static function format(font:String = "", size:int = 0, color:uint = 0, align:String = ""):void
		{
			if (font) Text.font = font;
			if (size) Text.size = size;
			if (color) Text.color = color;
			if (align) Text.align = align;
		}
		
		/**
		 * You can set the string for the Text object and its starting position in the contructor.
		 * @param	str	The string that the Text object should display.
		 * @param	x	The x-position to place it.
		 * @param	y	The y-position to place it.
		 */
		public function Text(str:String = "", x:int = 0, y:int = 0) 
		{
			_form = new TextFormat(Text.font, Text.size, Text.color, null, null, null, null, null, Text.align, null);
			_text = new TextField();
			_rect = new Rectangle();
			_text.embedFonts = true;
			_text.text = str;
			prepare();
			this.x = x;
			this.y = y;
		}
		
		/**
		 * The string that the Text object should display.
		 */
		public function get text():String
		{
			return _text.text;
		}
		public function set text(value:String):void
		{
			_text.text = value;
			prepare();
		}
		
		/**
		 * The embedded font-family to use.
		 */
		public function get font():String
		{
			return String(_form.font);
		}
		public function set font(value:String):void
		{
			_form.font = value;
			prepare();
		}
		
		/**
		 * The point-size of the font.
		 */
		public function get size():int
		{
			return int(_form.size);
		}
		public function set size(value:int):void
		{
			_form.size = value;
			prepare();
		}
		
		/**
		 * The color that the text should display.
		 */
		public function get color():uint
		{
			return uint(_form.color);
		}
		public function set color(value:uint):void
		{
			_form.color = value;
			_text.textColor = value;
			_data.draw(_text);
		}
		
		/**
		 * The alignment of the text. If you want a single-line of text to be centered without
		 * Flash player's font rendering blurring it, you can call center() instead, which will
		 * set the Text object's origin to its center.
		 * @see #center()
		 */
		public function get align():String
		{
			return String(_form.align);
		}
		public function set align(value:String):void
		{
			_form.align = value;
			prepare();
		}
		
		/**
		 * Use this to set multiple format values in one go.
		 * @param	font	The embedded font-family to use.
		 * @param	size	The point-size of the font.
		 * @param	color	The color that the text should display.
		 * @param	align	The alignment of the text.
		 */
		public function format(font:String = "", size:int = 0, color:uint = 0, align:String = ""):void
		{
			if (font) _form.font = font;
			if (size) _form.size = size;
			if (align) _form.align = align;
			if (color)
			{
				_form.color = color;
				_text.textColor = color;
			}
			prepare();
		}
		
		/**
		 * Centers the origin of the Text object. If you change the text, size, or font of the text, be
		 * aware that the origin may not be centered anymore if it changed width or height as a result.
		 */
		public function center():void
		{
			originX = width / 2;
			originY = height / 2;
		}
		
		/**
		 * Text will render its string to the screen at the correct position.
		 */
		override public function render():void 
		{
			_point.x = x - originX - FP.camera.x;
			_point.y = y - originY - FP.camera.y;
			FP.screen.copyPixels(_data, _rect, _point);
		}
		
		/** 
		 * @private prepares the display bitmap after formatting the text
		 */
		internal function prepare():void
		{
			_text.setTextFormat(_form);
			width = _text.textWidth + 4;
			height = _text.textHeight + 4;
			if (!_data || width > _data.width || height > _data.height)
			{
				if (_data) _data.dispose();
				_data = new BitmapData(width, height, true, 0);
				_rect.width = _text.width = width;
				_rect.height = _text.height = height;
			}
			else _data.fillRect(_rect, 0);
			_data.draw(_text);
		}
		
		// default font
		[Embed(source = 'core/04B_03__.TTF', fontFamily = "Default")] private const FontDefault:Class;
		
		// text properties
		/** @private */ internal var _text:TextField;
		/** @private */ internal var _form:TextFormat;
		/** @private */ internal var _data:BitmapData;
		/** @private */ internal var _rect:Rectangle;
		
		// global objects
		/** @private */ internal var _point:Point = FP.point;
	}
}