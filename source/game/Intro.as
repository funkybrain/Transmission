package game 
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import net.flashpunk.FP;
	import flash.utils.Timer;
	import net.flashpunk.utils.Input;
	import net.flashpunk.utils.Key;
	
	public class Intro
	{
		
		
		
		[Embed(source='../../assets/introTransmission.swf', symbol='wrapper')]
		private var _movie:Class;
		
		internal var introMovieClip:MovieClip;
		
		public function Intro() 
		{
			
			Input.define("Enter", Key.ENTER);
			
			init(_movie);
		}
		
		public function init(_clip:Class):void
		{
			
			introMovieClip = new _clip();
			
			introMovieClip.x = 0;
			introMovieClip.y = 0;
			
			introMovieClip.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);

			FP.stage.addChild(introMovieClip);
			
		}
		
		private function onAddedToStage(event:Event):void
		{
			//introMovieClip.stop(); // does nothing!
			trace("added to stage");
			introMovieClip.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			introMovieClip.addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);

		}
		
		private function onRemovedFromStage(event:Event):void
		{
			
			introMovieClip.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			introMovieClip.removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			introMovieClip.removeEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
			
			
			trace("removed all event listeners");


		}
		
		private function onEnterFrame(event:Event):void
		{
			
			if (introMovieClip.currentFrame == introMovieClip.totalFrames) 
			{
				// stop playing movie
				introMovieClip.stop();
				
				// check if user wants to start game
				
				if (Input.check("Enter")) 
				{
					FP.stage.removeChild(introMovieClip);
					trace("launch world");
					// call world
					FP.world = new Game;
				}
				
			}
		}
		
	}

}