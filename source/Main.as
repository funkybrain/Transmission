package
{
	
	import net.flashpunk.*;
	import rooms.*;
	import game.LoadXmlData;
	import splash.Splash;

	
	/**
	 * Main game class.
	 */
	public class Main extends Engine
	{
		
		private var data:LoadXmlData;

		/**
		 * Constructor. Start the game and set the starting world.
		 */
		public function Main() 
		{
			super(800, 480, 60, false);
			//TODO FP.world loads from LoadXmlData. revert to local load once no more tweaking of GD data
		}
		
		override public function init():void 
		{
			var s:Splash = new Splash;
			FP.world.add(s);
			s.start(splashComplete);
		}
		
		public function splashComplete():void
		{
			//Load gamedesign data
			data = new LoadXmlData();
		}
		
	}
}