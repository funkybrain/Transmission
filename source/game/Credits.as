package game 
{
	import flash.events.Event;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import net.flashpunk.utils.Input;
	import net.flashpunk.utils.Key;
	import net.flashpunk.tweens.misc.NumTween;
	import net.flashpunk.FP;
	
	
	public class Credits extends Intro
	{
	
		[Embed(source='../../assets/creditsTransmission.swf', symbol='wrapper')]
		private const _movie:Class;
		
		
		public function Credits() 
		{
			super();
			
		}
		
		override public function init(_clip:Class):void 
		{
			playIntro = false;
			super.init(_movie);
			
		}
		
		override public function onAddedToStage(event:Event):void 
		{
			movieSWF.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			movieSWF.addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
		}
		
		override public function onEnterFrame(event:Event):void 
		{

			if (movieSWF.currentFrame == movieSWF.totalFrames) 
			{
				// stop playing movie
				movieSWF.stop();
								
				/*if (Input.check("Enter")) 
				{
					// remove movie from stage
					FP.stage.removeChild(movieSWF);
					
					// fade out credit music handled in Game via CreditMusic Class
					
				}*/
				
			}
		}
		
	}

}