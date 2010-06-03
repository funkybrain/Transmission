package game 
{
	import net.flashpunk.Entity;
	import net.flashpunk.utils.Draw;
	
	
	public class Papyrus extends Entity
	{
		
		public function Papyrus(x:Number, y: Number, w:Number, h:Number) 
		{
			this.x = x;
			this.y = y;
			this.width = w;
			this.height = h;
			
			layer = 2;
		}
		
		override public function render():void 
		{
	
			super.render();
			
			// draw cache, same orange color as background image				
			Draw.rect(x, y, width, height, 0xDE3D21, 0.95);
						
		}
		
	}

}