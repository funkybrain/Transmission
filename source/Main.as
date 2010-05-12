﻿package
{
	import net.flashpunk.*;
	import rooms.*;
	
	/**
	 * Main game class.
	 */
	public class Main extends Engine
	{
		/**
		 * Constructor. Start the game and set the starting world.
		 */
		public function Main() 
		{
			super(800, 480, 60, false);
			FP.world = new Level;
		}
	}
}