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
	
		[Embed(source = '../../sounds/transmission.mp3', mimeType = 'audio/mpeg')]
			private static const SOUND_TRANSMIT:Class;
		
		[Embed(source = '../../sounds/MusiqueDebut.mp3', mimeType = 'audio/mpeg')]
			private static const MUSIC_START:Class;	
		
		
		/**
		 * Sound properties
		 */
		public var pathSound:Vector.<Sfx> = new Vector.<Sfx>(); // List<Sfx> to store path sounds/music
		public var pathFader:Vector.<SfxFader> = new Vector.<SfxFader>(); // List<SfxFader> to store path sounds faders
		
		public var transmitJingle:Sfx;
		
		public var musicStart:Sfx;
		public var startFader:SfxFader;
		

		
		
			
		public function SoundManager()
		{
			pathSound[0] = new Sfx(MUSIC_RED, null);
			pathSound[1] = new Sfx(MUSIC_GREEN, null);
			pathSound[2] = new Sfx(MUSIC_BLUE, null);
			
			pathFader[0] = new SfxFader(pathSound[0], _onFaderComplete);
			pathFader[1] = new SfxFader(pathSound[1], _onFaderComplete);
			pathFader[2] = new SfxFader(pathSound[2], _onFaderComplete);
			
			transmitJingle = new Sfx(SOUND_TRANSMIT);
			
			//musicEnd = new Sfx(MUSIC_END);
			//endFader = new SfxFader(musicEnd);

			processRules();
		}
		
		
		private function processRules():void
		{
			for each (var fader:SfxFader in pathFader) 
			{
				this.addTween(fader);
			}
			
			//this.addTween(endFader);
		}
		
		private function _onFaderComplete():void
		{
			// if this was called by a fade out, stop the music until the next resume
			// do nothing if it was called by a fade in
			// first make sur ALL music is muted - this would be an indication that all music should stop
			// and should also avoid stopping music if xfading between paths
			if (pathFader[0].sfx.volume==0 && pathFader[1].sfx.volume==0 && pathFader[2].sfx.volume==0) 
			{
				var j:int = 0;
				for each (var fader:SfxFader in pathFader) 
				{		
					fader.sfx.stop();
					trace("fader ("+ j +") Complete");
					trace("scrub ("+ j +") " + pathSound[j].position.toFixed(1));
					j++;
				}
			}
			
		}
		
	} // end SoundManager class

}