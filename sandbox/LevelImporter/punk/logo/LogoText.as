package punk.logo 
{
	import punk.Acrobat;
	import punk.core.Spritemap;
	
	/** @private */
	public class LogoText extends Acrobat
	{
		public function LogoText() 
		{
			sprite = FP.getSprite(ImgLogoText, 51, 12);
			loop = false;
			anim = animEnd;
			delay = 0;
			y += 41;
			color = Splash.front;
		}
		
		override public function update():void
		{
			if (_fadeWait > 0)
			{
				_fadeWait --;
				if (_fadeWait == 0) _fadeOut = true;
			}
			
			if (_fadeOut)
			{
				if (alpha > 0) alpha -= .02;
				else
				{
					alpha = 0;
					_endWait ++;
				}
				return;
			}
			
			// countdown to start writing out the letters
			if (_wait > 0)
			{
				_wait --;
				if (_wait == 0)
				{
					_state ++;
					if (_state == 3)
					{
						delay = 6;
					}
					else
					{
						delay = 1;
						FP.play(SndScribble, Splash.volume);
					}
				}
			}
			
			// play a sound during each letter of "Punk"
			if (image == 40 || image == 42 || image == 44 || image == 46)
			{
				if (!_punkSnd)
				{
					FP.play(SndBoing, Splash.volume);
					_punkSnd = true;
				}
			}
			else _punkSnd = false;
			
			// pause for a moment after the first word
			if (_state == 1 && image == 39)
			{
				delay = 0;
				_wait = 10;
				_state ++;
			}
		}
		
		// end of the animation
		private function animEnd():void
		{
			_fadeWait = 60;
		}
		
		// graphics
		[Embed(source = 'data/words.png')] private const ImgLogoText:Class;
		[Embed(source = 'data/scribble.mp3')] private const SndScribble:Class;
		[Embed(source = 'data/boing.mp3')] private const SndBoing:Class;
		
		// fading
		internal var _fadeOut:Boolean = false;
		internal var _fadeWait:int = 0;
		internal var _endWait:int = 0;
		
		// properties
		private var _wait:int = 30;
		private var _state:int = 0;
		private var _punkSnd:Boolean = false;
	}
}