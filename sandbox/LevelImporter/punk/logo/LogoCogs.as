package punk.logo 
{
	import flash.net.navigateToURL;
	import flash.net.URLRequest;
	import punk.Acrobat;
	import punk.util.Input;
	
	/** @private */
	public class LogoCogs extends Acrobat
	{
		public function LogoCogs() 
		{
			sprite = FP.getSprite(ImgLogoCogs, 68, 41);
			delay = 6;
			alpha = 0;
			color = Splash.front;
		}
		
		override public function update():void
		{
			if (alpha < 1) alpha += .01;
			if (!_spit && image == 3)
			{
				_spit = true;
				var heart:Acrobat = new LogoHeart(x + 58, y, this);
				heart.color = color;
				heart.alpha *= alpha;
				FP.world.add(heart);
			}
			if (image == 4) _spit = false;
			
			if (Splash.link && Input.mousePressed)
			{
				if (Input.mouseX > 0 && Input.mouseY > 0 && Input.mouseX < FP.screen.width && Input.mouseY < FP.screen.height)
				{
					var URL:URLRequest = new URLRequest("http://flashpunk.net");
					navigateToURL(URL, "_self");
				}
			}
		}
		
		// graphics
		[Embed(source = 'data/cogs.png')] private const ImgLogoCogs:Class;
		
		// spitting hearts
		private var _spit:Boolean = false;
	}
}