package game 
{
	import net.flashpunk.Sfx;
	import net.flashpunk.tweens.sound.*;
	import net.flashpunk.Tweener;
	
	public class SoundManager extends Tweener
	{
		/**
		 * Embedded sound library
		 */
		[Embed(source = '../../sounds/TransmissionHistoireChemin1.mp3', mimeType = 'audio/mpeg')]
			private static const MUSIC:Class;

		/**
		 * Sound properties
		 */
		private var mainTheme:Sfx;
		private var fader:SfxFader;
			
		public function SoundManager()
		{
			mainTheme = new Sfx(MUSIC, onComplete);
			
			mainTheme.volume = 1;
			mainTheme.play();
			
			//processRules();
			
		}
		
		private function onComplete():void
		{
			// this is just to test the function. I could loop() the sound and do away with this ^^
			mainTheme.play();
		}
		
		private function processRules():void
		{
			fader = new SfxFader(mainTheme, onFaderTweenFinish, 0);
			this.addTween(fader);
			fader.fadeTo(0, 10, null);
			//fader.start();
		
		}
		
		private function onFaderTweenFinish():void
		{
			mainTheme.stop()
			this.removeTween(fader);
		}
		
		
		
	} // end class

}