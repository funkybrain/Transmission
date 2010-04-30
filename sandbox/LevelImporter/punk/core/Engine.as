package punk.core
{
	import flash.display.StageAlign;
	import flash.display.StageQuality;
	import flash.display.StageScaleMode;
	import flash.display.StageDisplayState;
	import flash.system.System;
	import flash.display.Sprite;
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	import punk.logo.Splash;
	import punk.util.*;
	import punk.*;
	
	/**
	 * The FlashPunk base engine, runs your game loop and updates/renders your World.
	 */
	public class Engine extends Sprite
	{
		/**
		 * Set to true if you want your game to continue running when the Flash
		 * Player does not have focus. By default, your game loop will freeze.
		 */
		public var runUnfocused:Boolean = false;
		
		/**
		 * The Engine constructor defines important information about your game.
		 * @param	width	Unscaled width of your screen.
		 * @param	height	Unscaled height of your screen.
		 * @param	fps		Speed of your game loop (frames per second).
		 * @param	scale	Scale of your screen.
		 * @param	world	The class to initiate as the opening World, and so it must extend World.
		 */
		public function Engine(width:int = 320, height:int = 240, fps:int = 60, scale:int = 1, world:Class = null)
		{
			if (world == null) world = World;
			_start = world;
			_width = width;
			_height = height;
			FP.fps = fps;
			_scale = scale;
			
			// set the random seed to a random value if it hasn't already been set
			if (FP.randomSeed == 0) FP.randomizeSeed();
			
			// create FP's dummy entity
			FP.entity = new Entity;
			
			if (stage) onStage(null);
			else addEventListener(Event.ADDED_TO_STAGE, onStage);
		}
		
		/**
		 * Call this before the Engine's constructor to show the built-in FlashPunk splash screen. It is not mandatory to show this.
		 * @param	backColor	The background color of the splash screen.
		 * @param	logoColor	The logo color of the splash screen.
		 * @param	volume		The volume of the splash screen, a value from 0 to 1.
		 */
		public function showSplash(backColor:uint = 0x202020, logoColor:uint = 0xFF3366, volume:Number = .5, webLink:Boolean = false):void
		{
			Splash.show = true;
			Splash.volume = volume;
			Splash.link = webLink;
			Splash.back = backColor;
			Splash.front = logoColor;
		}
		
		/**
		 * The average framerate over the last second.
		 */
		public function get FPS():int
		{
			return _frameRate;
		}
		
		/**
		 * Override this. Called when the game starts, right before init() is called for the opening World.
		 */
		public function init():void
		{
			
		}
		
		// called when the Engine Sprite has been added to the stage
		private function onStage(e:Event = null):void
		{
			stage.align = StageAlign.TOP_LEFT;
			stage.quality = StageQuality.HIGH;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.displayState = StageDisplayState.NORMAL;
			
			removeEventListener(Event.ADDED_TO_STAGE, onStage);
			stage.frameRate = 60;
			
			_rate = 1000 / FP.fps;
			_skip = _rate * 10;
			_last = getTimer();
			_current = _last;
			_delta = 0;
			_timer = new Timer(4);
			_timer.addEventListener(TimerEvent.TIMER, tick);
			_timer.start();
			
			_frame = 0;
			_frameTime = 0;
			_frameRate = FP.fps;
			_frameTimer = new Timer(1000);
			_frameTimer.addEventListener(TimerEvent.TIMER, frameTick);
			_frameTimer.start();
			
			FP.stage = stage;
			FP.engine = this;
			FP.screen = new Screen(_width, _height, Splash.back, _scale);
			FP.camera = new Camera();
			
			_screenRect = FP.screen.rect;
			_bitmap = new Bitmap(FP.screen);
			_bitmap.scaleX = _scale;
			_bitmap.scaleY = _scale;
			addChild(_bitmap);
			
			Input.enable(stage);
			
			if (Splash.show) FP.world = new Splash(_start);
			else FP.world = new _start;
			
			stage.addEventListener(Event.ACTIVATE, focusGain);
			stage.addEventListener(Event.DEACTIVATE, focusLose);
			
			init();
			FP.world.init();
		}
		
		// when the game gains focus.
		private function focusGain(e:Event):void
		{
			_focus = true;
			if (FP.world !== null) FP.world.focusIn();
			if (!_timer.running)
			{
				_last = getTimer();
				_timer.start();
			}
		}
		
		// when the game loses focus.
		private function focusLose(e:Event):void
		{
			_focus = false;
			if (FP.world !== null) FP.world.focusOut();
		}
		
		// game ticker, compensates for lost frames by skipping render loops if it has to, but constantly updates
		private function tick(e:TimerEvent):void
		{
			_current = getTimer();
			_delta += _current - _last;
			_last = _current;
			
			if (_delta >= _rate)
			{
				_frame ++;
				_delta %= _skip;	// avoid too many frame-skips
				
				// game update
				while (_delta >= _rate)
				{
					_delta -= _rate;
					FP.world.updateF();
					Input.update();
				}
				
				// game render
				FP.screen.lock();
				FP.screen.fillRect(_screenRect, FP.screen.color);
				FP.world.renderF();
				FP.screen.unlock();
				e.updateAfterEvent();
				
				// switch worlds
				if (FP.goto) switchWorld();
				
				// freeze game when unfocused
				if (!_focus && !runUnfocused) _timer.stop();
			}
		}
		
		// switches the active world
		private function switchWorld():void
		{
			FP.world.removeAll();
			FP.world = FP.goto;
			FP.goto.init();
			FP.goto = null;
			System.gc();
			System.gc();
		}
		
		// calculates the framerate
		private function frameTick(e:TimerEvent):void
		{
			_frameRate = _frame;
			_frame = 0;
		}
		
		// screen buffer
		/** @private */ internal var _bitmap:Bitmap;
		/** @private */ internal var _screenRect:Rectangle;
		
		// the starting World class
		private var	_start:Class;
		
		// screen
		private var _width:int;
		private var	_height:int;
		private var	_scale:int;
		
		// game timer
		private var	_rate:Number;
		private var	_skip:Number;
		private var	_last:Number;
		private var	_current:Number;
		private var	_delta:Number;
		private var	_timer:Timer;
		
		// framerate
		private var	_frame:int;
		private var	_frameTime:Number;
		private var	_frameRate:int;
		private var	_frameTimer:Timer;
		
		// stage focus
		private var _focus:Boolean = true;
	}
}