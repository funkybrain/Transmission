package game 
{
	import net.flashpunk.Entity;
	import net.flashpunk.utils.Input;
	import net.flashpunk.utils.Key;
	import net.flashpunk.graphics.Text;
	import net.flashpunk.FP;
	import net.flashpunk.utils.Draw;
	
	public class Outro extends Entity
	{
			
		[Embed(source='../../assets/fonts/BMblock.TTF', fontFamily = 'block')]
		private static const FONT:Class;
				
		public var endMenu:Text;
			
		// set the upper-left corner of text box relative to camera position
		private var textBoxOffsetX:int = 50;
		private var textBoxOffsetY:int = 50;
		
		private var _text:String = "End of the line buddy..." + "\n\n\n" + "Press ENTER to play again";
		private var _x:uint = int(FP.camera.x) + textBoxOffsetX;
		private var _y:uint = int(FP.camera.y) + textBoxOffsetY;			
		private var _w:uint = 700;
		private var _h:uint = 400;
	
		public function Outro() 
		{
			// define end menu keys
			Input.define("Enter", Key.ENTER);
			Input.define("Esc", Key.ESCAPE);
			
			// place entity
			this.x = _x;
			this.y = _y;
			
			// initialize text
			// watch it, the x,y in constructor is the offset, not the position
			endMenu = new Text(_text, 50, 50, _w, _h);
			
			endMenu.font = "block";
			endMenu.size = 24;
			
			// assign entity's graphic to the Text object
			graphic = endMenu;
			layer = 0;
			
			trace(endMenu.text);
			trace("Outro added to world");
		}
		
		override public function render():void 
		{
			
			Draw.rect(_x, _y, _w, _h, 0x739EC2, 0.9);
			super.render();
		}
		
		override public function update():void 
		{
			super.update();
			endMenu.x = 120;
			endMenu.y = 100;
			
			if (Input.check("Enter") || Input.check("Esc")) 
			{
				
				//restart the world
				FP.world = new Game;
				
				//BUG shit, changing world keeps the music going!
			}
		}
		
	}

}