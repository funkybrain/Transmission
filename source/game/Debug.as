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
				Draw.hitbox(e, true, 0x498EE4);
				
			}
		}
		
		public function drawHitBoxOrigin(e:Entity):void {
			
			if (flag==true) 
			{
				//draw entity's origin on screen
				Draw.line(e.x - 2, e.y - 2, e.x + 2, e.y + 2);
				Draw.line(e.x + 2, e.y - 2, e.x - 2, e.y + 2);
				// draw rectangle around graphic's frame
				//Draw.rect((e.x + e.graphic.x), (e.y + e.graphic.y), 30, 30, 0x139608, 0.2);
				
			}
		}

		
	}

}