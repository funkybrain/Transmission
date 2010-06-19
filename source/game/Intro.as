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
		
		internal var movieSWF:MovieClip;
		
		public function Intro() 
		{
			
			Input.define("Enter", Key.ENTER);
			
			init(_movie);
		}
		
		public function init(_clip:Class):void
		{
			
			movieSWF = new _clip();
			
			movieSWF.x = 0;
			movieSWF.y = 0;
			
			movieSWF.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);

			FP.stage.addChild(movieSWF);
			
		}
		
		private function onAddedToStage(event:Event):void
		{
			//introMovieClip.stop(); // does nothing!
			trace("added movie to stage");
			movieSWF.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			movieSWF.addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);

		}
		
		public function onRemovedFromStage(event:Event):void
		{
			
			movieSWF.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			movieSWF.removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			movieSWF.removeEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
			
			
			trace("removed all event listeners from stage");


		}
		
		public function onEnterFrame(event:Event):void
		{
			
			if (movieSWF.currentFrame == movieSWF.totalFrames) 
			{
				// stop playing movie
				movieSWF.stop();
				
				// check if user wants to start game
				
				if (Input.check("Enter")) 
				{
					// remove movie from stage
					FP.stage.removeChild(movieSWF);
					
					// call world
					FP.world = new Game;
					trace("start game");
				}
				
			}
		}
		
	}

}