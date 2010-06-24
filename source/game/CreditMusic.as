package game 
{
	import net.flashpunk.Entity;
	import net.flashpunk.Sfx;
	import net.flashpunk.tweens.sound.SfxFader;
	import net.flashpunk.FP;

	public class CreditMusic extends Entity
	{
			
		[Embed(source = '../../sounds/MusiqueFin.mp3', mimeType = 'audio/mpeg')]
			private static const MUSIC_END:Class;	
	
				
		public var musicEnd:Sfx;
		public var fadeMusicIn:SfxFader;
		public var fadeMusicOut:SfxFader;
		
		
		public function CreditMusic() 
		{
			musicEnd = new Sfx(MUSIC_END);
			fadeMusicIn = new SfxFader(musicEnd, null, 2);
			fadeMusicOut = new SfxFader(musicEnd, onFadeOutComplete, 2);
			addTween(fadeMusicIn);
			addTween(fadeMusicOut);

		}
		
		private function onFadeOutComplete():void
		{
			//FP.world.removeAll();
			FP.world = new Game;

		}
		
	}

}