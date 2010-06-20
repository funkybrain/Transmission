package game 
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import net.flashpunk.Sfx;
	import net.flashpunk.tweens.sound.SfxFader;
	import net.flashpunk.FP;
	import flash.utils.Timer;
	import net.flashpunk.utils.Input;
	import net.flashpunk.utils.Key;
	
	public class Intro
	{	
		[Embed(source='../../assets/introTransmission.swf', symbol='wrapper')]
		private var _movie:Class;
		
		[Embed(source = '../../assets/introTransmission.swf', symbol = 'musiqueIntro')]
		private var _musicIntro:Class;
		
		internal var movieSWF:MovieClip;
		
		private var _music:Sfx;
		private var _musicFader:SfxFader;
		
		public function Intro() 
		{
			
			Input.define("Enter", Key.ENTER);
			FP.engine.stage.frameRate = 20;
			init(_movie);
		}
		
		public function init(_clip:Class):void
		{
			
			movieSWF = new _clip();
			_music = new Sfx(_musicIntro);
			_musicFader = new SfxFader(_music, onFadeComplete, 2);
			
			movieSWF.x = 0;
			movieSWF.y = 0;
			
			movieSWF.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			// add movie to stage
			FP.stage.addChild(movieSWF);
			
			// add music to world
			FP.world.addTween(_musicFader);
			
		}
		
		public function onFadeComplete():void
		{
			_music = null;
			// remove movie from stage
			FP.stage.removeChild(movieSWF);
					
			// call world
			FP.world = new Game;
			trace("start game");
		}
		
		private function onAddedToStage(event:Event):void
		{
			//introMovieClip.stop(); // does nothing!
			trace("added movie to stage");
			movieSWF.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			movieSWF.addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
			
			// play intro music
			_music.loop(1);

		}
		
		public function onRemovedFromStage(event:Event):void
		{
			
			movieSWF.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			movieSWF.removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			movieSWF.removeEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
			

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
					
					// fade out music
					_musicFader.fadeTo(0, 2);

				}
				
			}
		}
		
	}

}