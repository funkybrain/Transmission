﻿package game 
{
	import flash.display.BitmapData;
	import net.flashpunk.Entity;
	import net.flashpunk.FP;
	import net.flashpunk.graphics.Backdrop;
	import net.flashpunk.graphics.Graphiclist;
	import net.flashpunk.graphics.Image;
	
	/**
	 * Entity class for displaying the background.
	 */
	public class Background extends Entity
	{
		/**
		 * Embedded background graphic.
		 */
		[Embed(source = '../../assets/backgroundSprite.png')] private static const BACKGROUND:Class;
		
		/**
		 * Constructor.
		 */
		public function Background(x:int, y:int ) 
		{
			// set the background graphic and parallax rates.
			graphic = new Backdrop(BACKGROUND);
			this.x = x;
			this.y = y;
			graphic.scrollX = .5;
			graphic.scrollY = .5;
			
			// put it on layer 100, so it appears behind other entities.
			layer = 100;
		}
		
		/**
		 * Updates the background, makes it scroll.
		 */
		override public function update():void 
		{
			//x -= FP.elapsed * 20;
			//y -= FP.elapsed * 10;
		}
	}
}