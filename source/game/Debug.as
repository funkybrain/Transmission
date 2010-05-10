package game 
{
	import net.flashpunk.Entity;
	import net.flashpunk.graphics.Text;
	import net.flashpunk.utils.Draw;
	/**
	* Debug flag.
	*/
	public class Debug
	{	
		// flags debug mode on or off for the entire game
		public static var flag:Boolean=true;
		
		public function Debug() 
		{
		
		}
		
		public function drawHitBox(e:Entity):void {
			// draw entity's hitbox on screen
			if (flag==true) 
			{
				Draw.hitbox(e);
			}
		}
		

		
	}

}