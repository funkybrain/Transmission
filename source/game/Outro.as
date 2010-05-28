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
		private var _textBoxOffsetX:int = 50;
		private var _textBoxOffsetY:int = 40;
		
		private var _text:String = "End of the line buddy..." + "\n\n\n" + "Press ENTER to play again";
		
		private var _x:Number;
		private var _y:Number;			
		
		private var _w:uint = 700;
		private var _h:uint = 400;
		
	
		public function Outro() 
		{
			// define end menu keys
			Input.define("Enter", Key.ENTER);
			
			//Input.define("Esc", Key.ESCAPE);
			
			// place entity
			_x = FP.camera.x; // + textBoxOffsetX;
			_y = FP.camera.y; // + textBoxOffsetY;			
		
			this.x = _x;
			this.y = _y;
			
			// initialize text
			// update Text class with Chevy's hotfix
			endMenu = new Text(_text, 160, 130, _w, _h);
			endMenu.font = "block";
			endMenu.size = 24;
			
			// assign entity's graphic to the Text object
			graphic = endMenu;
			layer = 0;
		}
		
		override public function render():void 
		{
			
			Draw.rect(_x + _textBoxOffsetX, _y + _textBoxOffsetY, _w, _h, 0x739EC2, 0.9);
			super.render();
			
		}
		
		override public function update():void 
		{
						
			if (Input.check("Enter")) // did this bug because I hade the super.update() before it?
			{
				//restart the world
				FP.world = new Game;
			}

			super.update();

			/*	
			if (Input.check("Esc")) 
			{
				
				//exit the game... doh, you can't exit a flash game?
				
			}*/
		}
		
	}

}