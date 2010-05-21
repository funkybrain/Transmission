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
		public static var flag:Boolean=LoadXmlData.DEBUG;
		
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
		
		public function drawHitBoxOrigin(e:Entity):void {
			//TODO draw entity's hitbox origin on screen, currently displaying entity origin
			if (flag==true) 
			{
				Draw.line(e.x - 2, e.y - 2, e.x + 2, e.y + 2);
				Draw.line(e.x + 2, e.y - 2, e.x - 2, e.y + 2);
				
			}
		}

		
	}

}