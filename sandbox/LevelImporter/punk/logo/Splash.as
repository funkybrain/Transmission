package punk.logo
{
	import punk.core.*;
	
	/** @private */
	public class Splash extends World
	{
		// volume
		public static var volume:Number;
		
		// FlashPunk link
		public static var show:Boolean = false;
		public static var link:Boolean = false;
		public static var back:uint = 0x202020;
		public static var front:uint = 0xFF3366;
		
		public function Splash(world:Class = null) 
		{
			if (world == null) world = World;
			_world = world;
		}
		
		override public function init():void
		{
			// set the screen's background color
			FP.screen.color = back;
			
			// center the position of the logo
			_logoX = (FP.screen.width / 2) - 34;
			_logoY = (FP.screen.height / 1.5) - 27;
			
			// create the logo cogs
			_cogs = new LogoCogs();
			_cogs.x += _logoX;
			_cogs.y += _logoY;
			
			// create the logo text
			_text = new LogoText();
			_text.x += _logoX;
			_text.y += _logoY;
			
			// create & add the "powered by" text
			_pow = new LogoPow(_cogs, _text);
			_pow.x += _logoX;
			_pow.y += _logoY;
			add(_pow);
		}
		
		override public function update():void
		{
			if (_text._fadeOut) _cogs.alpha = _text.alpha;
			if (_text._endWait > 9) FP.goto = new _world();
		}
		
		override public function render():void
		{
			
		}
		
		// properties
		private var _world:Class = null;
		private var _logoX:int;
		private var _logoY:int;
		
		// objects
		private var _cogs:LogoCogs;
		private var _text:LogoText;
		private var _pow:LogoPow;
	}
}