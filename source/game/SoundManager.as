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
			
			pathFader[0] = new SfxFader(pathSound[0], _onFaderRedComplete);
			pathFader[1] = new SfxFader(pathSound[1], _onFaderGreenComplete);
			pathFader[2] = new SfxFader(pathSound[2], _onFaderBlueComplete);
			
			transmitJingle = new Sfx(SOUND_TRANSMIT);


			processRules();
		}
		
		
		private function processRules():void
		{
			for each (var fader:SfxFader in pathFader) 
			{
				this.addTween(fader);
			}
		}
		
		private function _onFaderRedComplete():void
		{
			// if this was called by a fade out, stop the music until the next resume
			// do nothing if it was called by a fade in
			// first make sur ALL music is muted - this would be an indication that all music should stop
			// and should also avoid stopping music if xfading between paths
			if (pathSound[0].volume==0 && pathSound[1].volume==0 && pathSound[2].volume==0) 
			{
				trace("onFaderRedComplete");
				var j:int = 0;
				for each (var sound:Sfx in pathSound) 
				{		
					if (sound.playing) 
					{
						sound.stop();
						trace("Sound ("+j+") Stopped - Scrub: " + pathSound[j].position.toFixed(1));
					}
					j++;
				}
			}
			
		}
		
		private function _onFaderGreenComplete():void
		{
			// if this was called by a fade out, stop the music until the next resume
			// do nothing if it was called by a fade in
			// first make sur ALL music is muted - this would be an indication that all music should stop
			// and should also avoid stopping music if xfading between paths
			if (pathSound[0].volume==0 && pathSound[1].volume==0 && pathSound[2].volume==0) 
			{
				trace("onFaderGreenComplete");
				var k:int = 0;
				for each (var sound:Sfx in pathSound) 
				{		
					if (sound.playing) 
					{
						sound.stop();
						trace("Sound (" + k + ") Stopped - Scrub: " + pathSound[k].position.toFixed(1));
					}					
					k++;
				}
			}
			
		}
		
		private function _onFaderBlueComplete():void
		{
			// if this was called by a fade out, stop the music until the next resume
			// do nothing if it was called by a fade in
			// first make sur ALL music is muted - this would be an indication that all music should stop
			// and should also avoid stopping music if xfading between paths
			if (pathSound[0].volume==0 && pathSound[1].volume==0 && pathSound[2].volume==0) 
			{
				trace("onFaderBlueComplete");
				var l:int = 0;
				for each (var sound:Sfx in pathSound) 
				{		
					if (sound.playing) 
					{
					sound.stop();
					trace("Sound (" + l + ") Stopped - Scrub: " + pathSound[l].position.toFixed(1));	
					}
					l++;
				}				
			}
		}
		
	} // end SoundManager class

}