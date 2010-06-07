package game 
{
	import net.flashpunk.graphics.Text;
	import net.flashpunk.Entity;
	import net.flashpunk.FP;
	
	public class GameOverlay extends Entity
	{
		public var timer:Text;
				
/*		[Embed(source='../../assets/fonts/BMblock.TTF', fontFamily = 'block')]
		private static const FNT_BLOCK:Class;*/
		
		[Embed(source='../../assets/fonts/ARIAL.TTF', fontFamily = 'over')]
		private static const FNT_ARIAL:Class;
		
		public function GameOverlay() 
		{
						
			this.x = FP.camera.x;
			this.y = 0;
			
			timer = new Text("", 710, 410, 100, 100);
			timer.font = "over";
			//timer.color = 0xBD8EF6;
			timer.size = 60;

			graphic = timer;
			layer = 0;
		}
		
		public function updateTimer(time:Number):void
		{
			timer.text = time.toString();
			this.x = FP.camera.x;
			//trace("timer: " + timer.text);
		}
		
		
	}

}