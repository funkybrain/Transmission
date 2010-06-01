package game 
{
	import net.flashpunk.Entity;
	import net.flashpunk.Sfx;
	import net.flashpunk.tweens.sound.*;
	import net.flashpunk.Tweener;
	
	public class SoundManager extends Entity
	{
		/**
		 * Embedded sound library
		 */
		[Embed(source = '../../sounds/Chemin1.mp3', mimeType = 'audio/mpeg')]
			private static const MUSIC_RED:Class;

		[Embed(source = '../../sounds/Chemin2.mp3', mimeType = 'audio/mpeg')]
			private static const MUSIC_GREEN:Class;

		[Embed(source = '../../sounds/Chemin3.mp3', mimeType = 'audio/mpeg')]
			private static const MUSIC_BLUE:Class;
	

		/**
		 * Sound properties
		 */
		public var pathSound:Vector.<Sfx> = new Vector.<Sfx>(); // List<Sfx> to store path sounds/music
		public var pathFader:Vector.<SfxFader> = new Vector.<SfxFader>(); // List<SfxFader> to store path sounds faders
		
			
		public function SoundManager()
		{
			pathSound[0] = new Sfx(MUSIC_RED, null);
			pathSound[1] = new Sfx(MUSIC_GREEN, null);
			pathSound[2] = new Sfx(MUSIC_BLUE, null);
			
			pathFader[0] = new SfxFader(pathSound[0], _onFaderNoughtComplete, 0);
			pathFader[1] = new SfxFader(pathSound[1], _onFaderOneComplete, 0);
			pathFader[2] = new SfxFader(pathSound[2], _onFaderTwoComplete, 0);

			processRules();
		}
		
		
		private function processRules():void
		{
			for each (var fader:SfxFader in pathFader) 
			{
				this.addTween(fader);
			}
			//fader.start();		
		}
		
		private function _onFaderNoughtComplete():void
		{
			// if this was called by a fade out, stop the music until the next resume
			if (pathFader[0].sfx.volume==0) 
			{
				pathFader[0].sfx.stop();
				trace("faderNought Complete");
			}
		}
		
		private function _onFaderOneComplete():void
		{
			// if this was called by a fade out, stop the music until the next resume
			if (pathFader[1].sfx.volume==0) 
			{
				pathFader[1].sfx.stop();
				trace("faderOne Complete");
			}
		}
		
		private function _onFaderTwoComplete():void
		{
			// if this was called by a fade out, stop the music until the next resume
			if (pathFader[2].sfx.volume==0) 
			{
				pathFader[2].sfx.stop();
				trace("faderTwo Complete");
			}
		}

		
		
		
	} // end SoundManager class

}