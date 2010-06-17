package game 
{
	import flash.events.Event;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	
	
	
	public class Credits extends Intro
	{
	
		[Embed(source='../../assets/creditsTransmission.swf', symbol='wrapper')]
		private const _movie:Class;
		
		[Embed(source='../../assets/creditsTransmission.swf', symbol='musiqueCredit')]
		private const _music:Class;
		
		public var music:Sound;
		public var fader:SoundChannel;
		
		public function Credits() 
		{
			//music = new _music();
			//fader = new SoundChannel();
			//fader = music.play();
			super();
		}
		
		override public function init(_clip:Class):void 
		{
			super.init(_movie);
		}
		
		override public function onRemovedFromStage(event:Event):void 
		{
			super.onRemovedFromStage(event);
			//fader.stop();
		}
		
	}

}