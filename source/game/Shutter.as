package game 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	import net.flashpunk.Entity;
	import net.flashpunk.Graphic;
	import net.flashpunk.graphics.Canvas;
	import net.flashpunk.graphics.Image;
	import net.flashpunk.utils.Draw;
	
	/**
	 * Shutter class is used to draw a sliding cache based on player path distance ratios
	 * 
	 * La longueur de l'écran est fonction du ratio du chemin x
	 * La hauteur de l'écran est fonction du ratio du chemin z
	 * Le chemin x est le chemin ayant le ratio le plus élevé
	 * le chemin z est celui ayant le ratio le moins élevé
	 * 
	 */
		
	public class Shutter extends Entity
	{

		 /**
		 * Textures
		 */
		[Embed(source = '../../assets/shutterTexture.png')] private const RIGHT:Class;
		[Embed(source = '../../assets/shutterTexture_DN.png')] private const DOWN:Class;
		[Embed(source = '../../assets/shutterTexture_UP.png')] private const UP:Class;
		
		 /**
		 * Class properties
		 */
		public var shutter:Image;
				 
		public function Shutter(x:int=0, y:int=0, pos:String="") 
		{
			this.x = x;
			this.y = y;
			type = "shutter";
			
			layer = 2;			
			
			// set the appropritae shutter graphic
			init(pos);
		}
		
		private function init(pos:String):void
		{
			switch (pos) 
			{
				case "right":
					shutter = new Image(RIGHT);
					shutter.x = 10; // offset by 10 pixel to avoir thin opening at screen edge
					break;
				case "up":
					shutter = new Image(UP);
					break;
				case "down":
					shutter = new Image(DOWN);
					break;
			}
			
			graphic = shutter;
			trace("create shutter " + pos);
		}
		
	}

}