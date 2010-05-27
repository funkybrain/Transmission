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
		
		private var _text:String = "End of the line buddy..." + "\n\n\n" + "Press ENTER to play again"; // + "\n\n\n" + "or Esc to quit";
		private var _x:uint = int(FP.camera.x) + textBoxOffsetX;
		private var _y:uint = int(FP.camera.y) + textBoxOffsetY;			
		private var _w:uint = 700;
		private var _h:uint = 400;
		
		private var _fadeToBlack:Curtain;
	
		public function Outro() 
		{
			// launch fade to black
			_launchFade();
			
			// define end menu keys
			Input.define("Enter", Key.ENTER);
			Input.define("Esc", Key.ESCAPE);
			
			// place entity
			this.x = _x;
			this.y = _y;
			
			// initialize text
			// update Text class with Chevy's hotfix
			endMenu = new Text(_text, 0, 0, _w, _h);
			endMenu.font = "block";
			endMenu.size = 24;
			
			// assign entity's graphic to the Text object
			graphic = endMenu;
			layer = 0;
			visible = false;
			
		
		}
		private function _launchFade():void
		{
			// fade to black
			_fadeToBlack = new Curtain(FP.width, FP.height, "out");		
			FP.world.add(_fadeToBlack);
		}
		
		override public function render():void 
		{
			
			if (_fadeToBlack.complete) 
			{
				Draw.rect(_x, _y, _w, _h, 0x739EC2, 0.9);

			}
			
			_fadeToBlack.x = FP.camera.x;
			_fadeToBlack.y = FP.camera.y;

			super.render();
			
		}
		
		override public function update():void 
		{
			super.update();
			
			if (_fadeToBlack.complete) 
			{
				endMenu.x = 120;
				endMenu.y = 100;
				visible = true;
			
				if (Input.check("Enter")) 
				{
				
				//restart the world
				FP.world = new Game;
				
				}
				
				if (Input.check("Esc")) 
				{
				
				//exit the game... doh, you can't exit a flash game?
				
				}
			}
			
			
		}
		
	}

}