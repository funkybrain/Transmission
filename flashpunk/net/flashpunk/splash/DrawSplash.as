package net.flashpunk.splash
{
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import net.flashpunk.Entity;
	import net.flashpunk.graphics.*;
	import net.flashpunk.tweens.misc.ColorTween;
	import net.flashpunk.FP;
	
	public class DrawSplash extends Entity
	{
		
		//load the image
		[Embed(source = 'splash.png')] public var imgSplash:Class;
		public var sprSplash:Image = new Image(imgSplash, new Rectangle(0,0,320, 80));
		
		//the time (how long it should take)
		public var _time:Number = 60;
		
		//alpha (for fading in/out)
		public var splashAlpha:ColorTween = new ColorTween;
		
		//whether we are fading in or fading out.
		public var fadeOut:Boolean = false;
		
		public var position:Point = new Point(0,0);
		
		
		public function DrawSplash(time:Number) 
		{
			//set the time
			_time = time;
			
			sprSplash.originX = sprSplash.width / 2;
			sprSplash.originY = sprSplash.height / 2;
			
			position = new Point(-sprSplash.width/2,-sprSplash.height/2)
			sprSplash.x = position.x;
			sprSplash.y = position.y;
			
			sprSplash.alpha = 0;
			
			//start the fading
			addTween(splashAlpha);
			splashAlpha.tween(time / 2, 0x000000, 0x000000, 0, 2);
			
			//set the graphic
			graphic = sprSplash;
			
			//set MY position
			x = FP.screen.width / 2;
			y = FP.screen.height / 2;
			
		}
		
		override public function update():void 
		{
			//if we're done fading, fade out
			if (splashAlpha.alpha == 2) 
			{
				splashAlpha.tween(_time / 2, 0x000000, 0x000000, 2, 0);
				fadeOut = true
			}
			
			//if we're done fading out, tell Splash.as that we are done....
			if (splashAlpha.alpha == 0 && fadeOut == true) 
			{ 
				Splash.end();
				return;
			}
			
			//update out alpha
			sprSplash.alpha = splashAlpha.alpha;
			
			//shake
			var amount:Number = (1 - Math.min((splashAlpha.alpha / 1.4), .95));
			sprSplash.angle = (amount * (Math.random() * 40)) - (amount * (Math.random() * 40));
			
			if (x == position.x) {
				sprSplash.x += Math.random() * (32*amount) - Math.random() * (32*amount);
				sprSplash.y += Math.random() * (32*amount) - Math.random() * (32*amount);
			} else {
				sprSplash.x = position.x;
				sprSplash.y = position.y;
			}
		}
		
	}

}