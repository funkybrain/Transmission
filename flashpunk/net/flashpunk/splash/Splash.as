package net.flashpunk.splash
{
	
	import net.flashpunk.World;
	import net.flashpunk.FP;
	import game.*;
	
	public class Splash extends World
	{
		
		public static var _goto:Class;
		
		
		/**
		 * Creates a simple Flash Punk Splash screen
		 * @param	goto		What world to go to after the splash screen has finished
		 * @param	bg			Background color
		 * @param	time		How long the Splash Screen should appear for
		 * @return	void
		 */
		public function Splash(goto:Class, bg:uint = 0x333333, time:Number = 60)
		{
			_goto = goto;
			
			FP.screen.color = bg;
			add(new DrawSplash(time));
		}
		
		//This function ends the splash screen and starts the next world.
		public static function end():void 
		{
			FP.world = new _goto;
		}
		
	}

}