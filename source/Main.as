package
{
	import net.flashpunk.*;
	import rooms.*;
	import game.LoadXmlData;
	
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

			//Load gamedesign data
			//TODO FP.world loads from LoadXmlData. revert to local load once no more tweaking of GD data
			data = new LoadXmlData();
			

		}

	}
}