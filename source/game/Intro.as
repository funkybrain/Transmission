package game 
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import net.flashpunk.FP;
	import flash.utils.Timer;
	
	public class Intro
	{
		
		
		
		[Embed(source='../../assets/introMovie.swf', symbol='introClip')]
		private var _movie:Class;
		
		public var introMovieClip:MovieClip;
		
		// remove this
		public var myTimer:Timer = new Timer(1000, 0);
		
		public function Intro() 
		{
			init();
		}
		
		public function init():void
		{
			
			introMovieClip = new _movie();
			
			introMovieClip.x = 150;
			introMovieClip.y = 150;
			
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
			
			// remove this
			myTimer.removeEventListener(TimerEvent.TIMER, timerListener);
			
			trace("removed all event listeners");
			FP.world = new Game;
		}
		
		private function onEnterFrame(event:Event):void
		{
			
			if (introMovieClip.currentFrame == introMovieClip.totalFrames && !myTimer.running) 
			{
				
				// this is temporary - also remove the condition in the if
				myTimer.addEventListener(TimerEvent.TIMER, timerListener);
				myTimer.start();
				trace("start timer");
				
				
				// once the fade to balck is inside the clip, just use these two lines
				introMovieClip.stop();
				//FP.stage.removeChild(introMovieClip);
				
			}
		}
		
		//remove this
		private function timerListener (e:TimerEvent):void
		{
				trace("Timer is Triggered");
				FP.stage.removeChild(introMovieClip);
		}
		
		
	}

}