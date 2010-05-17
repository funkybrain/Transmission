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
			private static const MUSIC_RED:Class;

		[Embed(source = '../../sounds/TransmissionHistoireChemin2.mp3', mimeType = 'audio/mpeg')]
			private static const MUSIC_GREEN:Class;

		[Embed(source = '../../sounds/TransmissionHistoireChemin3.mp3', mimeType = 'audio/mpeg')]
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
			
			pathFader[0] = new SfxFader(pathSound[0], null, 0);
			pathFader[1] = new SfxFader(pathSound[1], null, 0);
			pathFader[2] = new SfxFader(pathSound[2], null, 0);

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

		
		
		
	} // end SoundManager class

}