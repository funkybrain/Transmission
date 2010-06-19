package game 
{
	import flash.display.InteractiveObject;
	import utils.SWFProfiler;
	import net.flashpunk.graphics.Canvas;
	import net.flashpunk.graphics.Spritemap;
	import net.flashpunk.Sfx;
	import net.flashpunk.tweens.misc.VarTween;
	import net.flashpunk.tweens.sound.SfxFader;
	import net.flashpunk.tweens.sound.Fader;
	import net.flashpunk.World;
	import net.flashpunk.utils.Input;
	import net.flashpunk.utils.Key;
	import rooms.Level;
	import game.Debug;
	import game.LoadXmlData;
	import game.PathRed;
	import game.PathBlue;
	import game.PathGreen;
	import game.PathTile;
	import game.Player;
	import game.Robot;
	import game.SoundManager;
	import game.Background;
	import game.Animation;
	import game.Shutter;
	import net.flashpunk.Entity;
	import net.flashpunk.FP;
	import net.flashpunk.graphics.Anim;
	import net.flashpunk.graphics.Text;
	import net.flashpunk.tweens.misc.Alarm;
	import net.flashpunk.tweens.misc.NumTween;
	import net.flashpunk.utils.Ease;
	import net.flashpunk.utils.Draw;
	import flash.geom.Point;
	import utils.SWFProfiler;
	import game.CreditMusic;
	
	public class Game extends World
	{
		
		/**
		 * Levels
		 */
		public var level_1:Level;
		public var level_2:Level;
		
		
		/**
		 * Fonts.
		 */
		[Embed(source = '../../assets/fonts/EMLATIN6.ttf', fontFamily = 'debugFont')]
		private static const FNT_ARIAL:Class;

		
		
		/**
		 * Camera following information.
		 */
		public const FOLLOW_TRAIL:Number = 50;
		public const FOLLOW_RATE:Number = .9;
		public var worldWidth:uint;
		public var worldHeight:uint;
				
		/**
		 * Debug variables.
		 */		

		public var debug:Debug;
		public var debugText:Text;
		public var debugHUD:Entity;
		
		/**
		 * Game (transmission) specific variables.
		 */
		public var data:LoadXmlData;
		 
		
		
		public var player:Player;
	
		public var vectorZero:Point = new Point();
		
		private var _overlay:GameOverlay;

		
		// List<Animation> to store background animations
		public var animationList:Vector.<Animation> = new Vector.<Animation>();
		public var backgroundList:Vector.<Background> = new Vector.<Background>();
		
		
		/**
		 * Special effects and Tweens
		 */
		
		// camera Tween
		private var _cameraPan:NumTween;
		 
		// Sound Tweens
		public var masterfader:NumTween;
		
		// Shutters 
		private var _shutterRight:Shutter;
		private var _shutterRightTween:NumTween;
		
		private var _shutterUp:Shutter;
		private var _shutterUpTween:NumTween;
		
		private var _shutterDown:Shutter;
		private var _shutterDownTween:NumTween;
		
		private var _shutterChangeState:int = 3;
		
		// Fade in screen
		private var _fadeInCurtain:Curtain;
		
		
		/**
		 * Rouleau
		 */
		public var rouleauStart:Rouleau;
		public var rouleauEnd:Rouleau;
		public var rouleauTriggerX:int;
		public var papyrus:Papyrus;
		public var rollFrom:Number=0;
		
		/**
		 * Booleans
		 */
		private var _creditsCalled:Boolean = false;
		private var _masterFaderComplete:Boolean = true;
		private var _levelTwoAdded:Boolean = false;
		private var _rouleauTriggered:Boolean = false;
		private var _inContact:Boolean = false;
		

		public var playerGoneAWOL:Boolean = false;
		public var launchEndMusic:Boolean = false;

		/**
		 * Epitaphe
		 */ 
		public var finalWords:Epitaphe;

		/**
		 * Music for credits
		 */
		public var creditMusic:CreditMusic;
		
		/**
		 * For debug
		 */
		private var _counter:Number = 0;
		
		/**
		 * CONSTRUCTOR
		 */
		public function Game() 
		{	
			// create first level
			level_1 = new Level(1, 0);
			
			// get trigger for rouleau
			rouleauTriggerX = level_1.getTriggerPosition();
			trace("trigger X : " + rouleauTriggerX); 
			
			// set intial camera clamp value to level width/height
			worldWidth = level_1.width;
			worldHeight = level_1.height;
			
			// add level objects to world
			level_1.addObjectsToWorld(this)
			backgroundList = level_1.addBackgroundsToWorld(this);
			
			// add level animations to world and retrieve List<Animation>
			animationList = level_1.addBackgroundAnimationsToWorld(this);
			
			// add player to world
			player = level_1.addPlayerToWorld(this);
			
			// add rouleau to world
			rouleauStart = new Rouleau();
			add(rouleauStart);
			
			// add debug hud to world
			debug = new Debug();
			debugHUD = new Entity();
			debugHUD.x = 10;
			debugHUD.y = 10;
			add(debugHUD);
			
			debugText = new Text("", 0, 0, 400, 100);
			debugText.font = "debugFont";
			
			//
			Input.define("Enter", Key.ENTER);
			
			// refresh screen color
			FP.screen.color = 0x808080;
			
			// fade game in
			fadeCurtainIn();

			// add game overlay
			_overlay = new GameOverlay();
			add(_overlay);
			
			// initialize shutters
			initShutters();
			
			//TODO remove kill vol befor publish
			FP.volume = LoadXmlData.VOLUME;
			
						
		} // end constructor
		
		/**
		 * Create the inital fade in as the game appears
		 */
		public function fadeCurtainIn():void
		{
			_fadeInCurtain = new Curtain(FP.width, FP.height, "in");
			add(_fadeInCurtain);
			trace("fade In");
			
		}
		
		/**
		 * Initialize shutters for game
		 */
		private function initShutters():void
		{
			_shutterRight = new Shutter(FP.width - 200, 0, "right");
			_shutterDown = new Shutter(0, FP.height - 120, "up");
			_shutterUp = new Shutter(0, 0, "up");
			
			_shutterDownTween = new NumTween();
			_shutterRightTween = new NumTween();
			_shutterUpTween = new NumTween();
			
			addTween(_shutterRightTween);
			addTween(_shutterDownTween);
			addTween(_shutterUpTween);
			
			addList(_shutterDown, _shutterRight, _shutterUp);
		}
		
		/**
		 * UPDATE LOOP FOR GAME
		 */
		override public function update():void 
		{
			// update debug game time counter
			_counter += FP.elapsed;
			
			// update entities
			super.update();
			
			// update rouleau position
			updateRouleauPositions();
			
			// unravel final words
			if (null != finalWords) 
			{
				// update the text length of final words
				updateFinalWords();
			}
			
			// update path ratios
			player.calculatePathRatios();

			// update shutter positions
			updateShutters();
			
			//test to see if we're near game end
			checkGrandChildNearDeath();
			
			// update debug text
			updateDebugText();
			
			// draw progress bar
			var bar:int = FP.scaleClamp(player.x, 0, 7980 * 2, 0, _overlay.maxLength);
			_overlay.drawProgressBar(bar);
			
			// camera following
			cameraFollow();
			
			// freeze or unfreeze timers and sounds
			checkTimers();
			
			
			//set backgound animation framerates based on player speed
			setAnimationSpeed();
			
			// if final fade out is finished, send-in Credits
			if (null != player.fadeOutCurtain && player.fadeOutCurtain.complete) 
			{
				callCredits();
			}
			
			
			
			// test to see if next level needs to be imported
			if (FP.camera.x > (level_1.width - FP.width - 100) && !_levelTwoAdded) 
			{
				importNextLevel();
				_levelTwoAdded = true;
				trace("import level2");
			}
			
			// clean-up animation and background list to save on memory
			removeAnimations();
			removeBackgrounds();
			
			// check to see if player has triggered rouleau
			if (rouleauStart.x > rouleauTriggerX && !_rouleauTriggered) 
			{
					_rouleauTriggered = true;
					// start a tween on the camera to slowly bring the player to the right third of screen
					_cameraPan = new NumTween(onCameraPan, 2);
					_cameraPan.tween((FP.width / 2), (FP.width / 1.5), 25, Ease.expoIn);
					addTween(_cameraPan);
					_cameraPan.start();
					
					// start Epitaphe
					startFinalWords();
			}

			// debug
			if (null != _cameraPan && _cameraPan.active)
			{
				//trace("cam pan: " + _cameraPan.value);
			}
			
			
			// fade volume out when grandchild is dying
			if (player.deathImminent && !launchEndMusic) 
			{
				//FP.volume = masterfader.value;
				//set the volume to the alpha value of the grandChild as it fades out
				//FP.volume = player.grandChild.alpha;
				//trace("vol: " + FP.volume);
				for (var i:int = 0; i < 3; i++) 
				{
					player.fadeOutPathMusic(i);
				}
				
				
				trace("end music kicks in");
				launchEndMusic = true;
				
				// call end music. starts during death scene and extends to credits
				fadeInEndMusic();
			}
			
			
			// hide/show overlay
			if (LoadXmlData.HUD) 
			{
				_overlay.visible = true;
			} else _overlay.visible = false;
			
			
			// check to see if it's time to kill the credit music
			if (Input.check("Enter") &&  player.isPlayerDead && !creditMusic.fadeMusicOut.active)
			{
				trace("player hit Enter - kill credit music");
				fadeOutEndMusic();
			}
			
		}
		// end Game UPDATE LOOP
		
		
				
	
		

		
		/**
		 * Camera pan event when epitaphe starts to appear
		 */
		private function onCameraPan():void
		{
			trace("camera pan complete");
		}
		
		/**
		 * RENDER LOOP FOR GAME
		 */
		override public function render():void 
		{
			super.render();
			
			if (LoadXmlData.DEBUG) 
			{
				Draw.rect(FP.camera.x, FP.camera.y, 350, 95, 0x24323F, 0.99);// overlay for debug text
			}
			
			debug.drawHitBox(player);
			debugHUD.render();
			debug.drawHitBoxOrigin(player);
			
			
		}
		// end Game RENDER LOOP
		
		/**
		 * Import new level
		 */
		private function importNextLevel():void
		{
			// create first level
			level_2 = new Level(2, worldWidth);
			trace("level2 imported");
			
			// get trigger for rouleau
			if (rouleauTriggerX >= 50000) // true if trigger was NOT loaded in the first level
			{
				rouleauTriggerX = level_2.getTriggerPosition();
				trace("trigger X : " + rouleauTriggerX); 

			}
			
			// set intial camera clamp value to level width/height
			worldWidth += level_2.width;
			trace("worldWidth: " + worldWidth);
			
			// add level objects to world
			level_2.addObjectsToWorld(this)
			
			// add backgrounds to World
			backgroundList = backgroundList.concat(level_2.addBackgroundsToWorld(this));
			
			// add level animations to world and retrieve List<Animation>
			animationList = animationList.concat(level_2.addBackgroundAnimationsToWorld(this));
		}
		
		/**
		 * Check state of player to see if timers and sound should be frozen/unfrozen
		 */
		public function checkTimers():void
		{
			// need to check alarm states
			// those only affect those that have already started
			
			if (player.wasMoving==false && !player.velocity.equals(vectorZero)) 
			{
				player.isMoving = true;				
			}
			
			if (player.wasMoving==true && player.velocity.equals(vectorZero)) 
			{
				player.isMoving = false;				
			}
			
			for each (var timer:Alarm in player.timers) 
			{
				// freeze timers unless grandchild death is imminent
				if (timer.active == true && !player.deathImminent)
				{
					if (player.isMoving == false  || !player.hasControl) 
					{
						timer.active = false;
					}
				}
				
				
				
				//unfreeze timers
				if (timer.active == false)
				{
					if (player.isMoving == true && player.hasControl) 
					{
						timer.active = true;	
					}
				}
				
			}
		}
		// end checkTimers()
		
		/**
		 * Update shutter positions
		 */
		public function updateShutters():void
		{
			var debug:Boolean = true;
			
			var maxR:Number = player.getRatx();
			var minR:Number = player.getRatz();
			//trace("maxR " +maxR + "minR " +minR);
			
			var triggerLimit:Number = 1000;
			
			/************************/
			/* Setup shutter presets*/
			/************************/
			
			/* RIGHT shutter*/
			var shutterRightClosed:Number = FP.width - 200;					
			var shutterRightMid:Number = FP.width - 100;
			var shutterRightOpen:Number = FP.width - 20;
			
			_shutterRight.y = 0;
						
			/* UP shutter */
			var shutterUpClosed:Number = -10;					
			var shutterUpMid:Number = - 40;
			var shutterUpOpen:Number =  - 110;
			
			_shutterUp.x = FP.camera.x;

			/* DOWN shutter */
			var shutterDownClosed:Number = FP.height - 110;					
			var shutterDownMid:Number = FP.height - 80;
			var shutterDownOpen:Number = FP.height - 10;
			
			_shutterDown.x = FP.camera.x;			
			
			// all shutter stay closed until player reaches trigger limit
			if (player.totaldistance < triggerLimit) 
			{
				_shutterRight.x = FP.camera.x + shutterRightClosed;
				_shutterUp.y = shutterUpClosed;
				_shutterDown.y = shutterDownClosed;
			}
			
			/*************************************************************************
			 ****    MODEL 1A                                                    *****
			 ****  0.6<maxR<1 and 0=<minR<0.2                                  *******
			 ****                                                              *******
			 * also applies if player inherited model 1a but not yet at speed type 3 *
			 ************************************************************************/
			
			if ((maxR > 0.6 && minR < 0.2 && player.totaldistance >= triggerLimit)
				|| (player.transmitModel == 0 && !player.type3))
			{
				
				/* RIGHT shutter */
				
				// change of state - start the tween
				if (!_shutterRightTween.active && _shutterChangeState !=0) 
				{
					// tween open the shutter
					_shutterRightTween.tween((_shutterRight.x-FP.camera.x), shutterRightOpen, 4, Ease.sineIn);
					_shutterRightTween.start();
				}
				
				// tween active - update shutter position
				if (_shutterRightTween.active) 
				{
					_shutterRight.x = FP.camera.x + _shutterRightTween.value;
				}
				
				// tween not active and no change of state - shutter should be open
				if (!_shutterRightTween.active && _shutterChangeState == 0) 
				{
					_shutterRight.x = FP.camera.x + shutterRightOpen;
				}
				
				/* UP shutter */

				// change of state - start the tween
				if (!_shutterUpTween.active && _shutterChangeState !=0) 
				{
					_shutterUpTween.tween(_shutterUp.y, shutterUpClosed, 4, Ease.sineIn);
					_shutterUpTween.start();
				}
				
				// tween active - update shutter position
				if (_shutterUpTween.active) 
				{
					_shutterUp.y = _shutterUpTween.value;
				}
				
				// tween not active and no change of state - shutter should be closed
				if (!_shutterUpTween.active && _shutterChangeState == 0) 
				{
					_shutterUp.y = shutterUpClosed;
				}
				
				
				
				/* DOWN shutter */		

				// change of state - start the tween
				if (!_shutterDownTween.active && _shutterChangeState !=0) 
				{
					_shutterDownTween.tween(_shutterDown.y, shutterDownClosed, 4, Ease.sineIn);
					_shutterDownTween.start();
				}
				// tween active - update shutter position
				if (_shutterDownTween.active) 
				{
					_shutterDown.y = _shutterDownTween.value;
				} else _shutterDown.y = shutterDownClosed;
				
				// tween not active and no change of state - shutter should be closed
				if (!_shutterDownTween.active && _shutterChangeState == 0) 
				{
					_shutterDown.y = shutterDownClosed;
				}
				
				
				//debug
				if (_counter > 0.4 && debug && _shutterChangeState != 0) 
				{
					_counter -= _counter;
					trace("modele 1a");
					
					if (_shutterRightTween.active) 
					{
						trace(_shutterRightTween.value);
					}
				}
				
				// set new shutter state
				_shutterChangeState = 0;
				
			}
			
			/*************************************************************************
			 ****    MODEL 1B                                                     ****
			 ****  0.43=<maxR=<0.6                                                ****
			 ****  0=<minR<0.15                                                   ****
			 * also applies if player inherited model 1b but not yet at speed type 3 *
			 ************************************************************************/
			
			else if ((maxR >= 0.43 && maxR <= 0.6 && minR <= 0.15
				&& player.totaldistance >= triggerLimit) || (player.transmitModel == 1 && !player.type3))
			{	
				/* RIGHT shutter */
				// change of state - start the tween
				if (!_shutterRightTween.active && _shutterChangeState !=1) 
				{
					_shutterRightTween.tween((_shutterRight.x-FP.camera.x), shutterRightMid, 4, Ease.sineIn);
					_shutterRightTween.start();
				}
				
				// tween active - update shutter position
				if (_shutterRightTween.active) 
				{
					_shutterRight.x = FP.camera.x + _shutterRightTween.value;
				}
				
				// tween not active and no change of state - shutter should be at mid position
				if (!_shutterRightTween.active && _shutterChangeState == 1) 
				{
					_shutterRight.x = FP.camera.x + shutterRightMid;
				}
				
				
				/* UP shutter */
				// change of state - start the tween
				if (!_shutterUpTween.active && _shutterChangeState !=1) 
				{
					_shutterUpTween.tween(_shutterUp.y, shutterUpMid, 4, Ease.sineIn);
					_shutterUpTween.start();
				}
				// tween active - update shutter position
				if (_shutterUpTween.active) 
				{
					_shutterUp.y = _shutterUpTween.value;
				}
				
				// tween not active and no change of state - shutter should be at mid position
				if (!_shutterUpTween.active && _shutterChangeState == 1) 
				{
					_shutterUp.y = shutterUpMid;
				} 
				
				/* DOWN shutter */					
				// change of state - start the tween
				if (!_shutterDownTween.active && _shutterChangeState !=1) 
				{
					_shutterDownTween.tween(_shutterDown.y, shutterDownMid, 4, Ease.sineIn);
					_shutterDownTween.start();
				}
				
				// tween active - update shutter position
				if (_shutterDownTween.active) 
				{
					_shutterDown.y = _shutterDownTween.value;
				}
				
				// tween not active and no change of state - shutter should be at mid position
				if (!_shutterDownTween.active && _shutterChangeState == 1) 
				{
					_shutterDown.y = shutterDownMid;
				}
				
				
				//debug
				if (_counter > 0.4 && debug && _shutterChangeState != 1) 
				{
					_counter -= _counter;
					trace("modele 1b");
					
					if (_shutterRightTween.active) 
					{
						trace(_shutterRightTween.value);
					}
				}
				
				// set new shutter state
				_shutterChangeState = 1;
				

			}
			
			/************************
			 ****   MODEL2    *******
			 **** 0.34=<ratx=<0.6  **
			 **** 0.15=<ratz<0.33 ***
			 * also applies if type3*
			 * or model 2           *
			 ************************/

			else if ((maxR >= 0.34 && maxR <= 0.6 && minR >= 0.15 && minR <= 0.33
				&& player.totaldistance >= triggerLimit) || player.transmitModel == 2 || player.type3)
			{
				/* RIGHT shutter */
				// change of state - start the tween
				if (!_shutterRightTween.active && _shutterChangeState !=2) 
				{
					_shutterRightTween.tween((_shutterRight.x-FP.camera.x), shutterRightClosed, 4, Ease.sineIn);
					_shutterRightTween.start();
				}
				
				// tween active - update shutter position
				if (_shutterRightTween.active) 
				{
					_shutterRight.x = FP.camera.x + _shutterRightTween.value;
				}
				
				// tween not active and no change of state - shutter should be at closed position
				if (!_shutterRightTween.active && _shutterChangeState == 2) 
				{
					_shutterRight.x = FP.camera.x + shutterRightClosed;
				}
				
				/* UP shutter */
				// change of state - start the tween
				if (!_shutterUpTween.active && _shutterChangeState !=2) 
				{
					_shutterUpTween.tween(_shutterUp.y, shutterUpOpen, 4, Ease.sineIn);
					_shutterUpTween.start();
				}
				
				// tween active - update shutter position
				if (_shutterUpTween.active) 
				{
					_shutterUp.y = _shutterUpTween.value;
				}
				
				// tween not active and no change of state - shutter should be at open position
				if (!_shutterUpTween.active && _shutterChangeState == 2) 
				{
					_shutterUp.y = shutterUpOpen;
				}
				
				/* DOWN shutter */		
				// change of state - start the tween
				if (!_shutterDownTween.active && _shutterChangeState !=2) 
				{
					_shutterDownTween.tween(_shutterDown.y, shutterDownOpen, 4, Ease.sineIn);
					_shutterDownTween.start();
				}
				
				// tween active - update shutter position
				if (_shutterDownTween.active) 
				{
					_shutterDown.y = _shutterDownTween.value;
				} else _shutterDown.y = shutterDownOpen;
			
				// tween not active and no change of state - shutter should be at open position
				if (!_shutterDownTween.active && _shutterChangeState == 2) 
				{
					_shutterDown.y = shutterDownOpen;
				}	
					
				
				//debug
				if (_counter > 0.4 && debug && _shutterChangeState != 2) 
				{
					_counter -= _counter;
					trace("modele 2");
					
					if (_shutterRightTween.active) 
					{
						trace(_shutterRightTween.value);
					}
				}
				
				// set new shutter state
				_shutterChangeState = 2;
				
			}
		}

		
		/**
		 * Test to see if GrandChild is close to death
		 */
		public function checkGrandChildNearDeath():void
		{
			
			if (player.timeGrandChildToEnd.remaining <= 10 && player.deathImminent==false) 
			{
				startDeathSequence(10); // 10 seconds to death
				player.deathImminent = true;
			}

		}
		
		/**
		 * GrandChild starts to disappear
		 * 
		 * @param	time	countdown to disapearance starts at this time (in sec)
		 */
		public function startDeathSequence(time:Number):void
		{
			//fade player sprite out
			player.fadeSprite.tween(player.grandChild, "alpha", 0.1, time, Ease.expoOut);
			player.addTween(player.fadeSprite);
			player.fadeSprite.start();
			
			// fade music out
			/*masterfader = new NumTween();
			masterfader.tween(FP.volume, 0, time, Ease.circOut);
			addTween(masterfader);
			masterfader.start();*/
			
			// set flag for mechanics that need to know the death sequence has started
			

		}
		
		/**
		 * Generate final words
		 */
		
		private function startFinalWords():void
		{
			// add Epitaphe object
			finalWords = new Epitaphe();
			finalWords.visible = false;
			finalWords.x = rouleauStart.x + rouleauStart.spriteRouleau.width + 5;
			trace("final words x " + finalWords.x);
			add(finalWords);

			// add the second rouleau that unravels
			rouleauEnd = new Rouleau();
			//rouleauEnd.spriteRouleau.color = 0xA7B6EC;
			rouleauEnd.x = rouleauStart.x + rouleauStart.spriteRouleau.width;
			add(rouleauEnd);
			
			// add underlying paper
			papyrus = new Papyrus((rouleauStart.x + rouleauStart.spriteRouleau.width),0, 0, FP.screen.height);
			add(papyrus);
			
		}
		
		
		/**
		 * unravel the words as player moves
		 */
		private function updateFinalWords():void
		{
			// display one character every 25 pixels the player moves
			var wordslength:int = (player.x - rouleauTriggerX) / 25;
			var letterWidth:int = 10; // average width of one letter
			
			//trace("wordslength: " + wordslength);
			
			finalWords.unravelFinalWord(wordslength);
			
			// move final words forward to keep up with player
			if (player.isMoving) 
			{
				finalWords.x += 0.2; // need to scale it to player speed and only fior up/down moves
			}
			
			if (wordslength > 1) 
			{
				finalWords.visible = true;

			}
			
/*			if (wordslength > 10) 
			{
				finalWords.supportSyllogisme.scrollX = 0.9;
			}*/
			
		}
		
		
		/**
		 * Update rouleau positions and animations
		 */
		private function updateRouleauPositions():void
		{
			
			var contactPoint:Number = player.x 
					+ (player.graphic as Spritemap).width / 2 * (player.graphic as Spritemap).scale;
			
			if (player.collide("rouleau", contactPoint, player.y)) 
			{
				_inContact = true;
			} else _inContact = false;
				 
			
			if (_inContact && !rouleauStart.isSpinning && !_inContact) 
			{
				trace("made new contact ");		
			}
			//trace("in contact: " + _inContact);
			
			if (rouleauStart != null && !_rouleauTriggered) 
			{
				
				if (_inContact && !rouleauStart.isSpinning)
				{
					var test:Boolean = player.rightArrowReleased();
					//trace("arrow released: " + test);
					if (test || !player.hasControl)
					{
						rouleauStart.rollFree();
						//_inContact = false;
						rollFrom = rouleauStart.x;
					}
				}
				
				
				rouleauStart.x = Math.max(rouleauStart.previousX, contactPoint,	
					(rollFrom + rouleauStart.inertieX));
				
				// animate rouleau based on player speed
				if (player.hasControl && _inContact && !rouleauStart.isSpinning) 
				{
					rouleauStart.spriteRouleau.rate = FP.scaleClamp(player.velocity.x, 0, 2, 0, 1) * FP.frameRate * FP.elapsed;
				}
				
				
				// debug
/*				if (_counter>0.4) 
				{
					_counter -= _counter;
					trace("spinning: " + rouleauStart.isSpinning);
					trace("in contact: " + _inContact);
					trace("inertieX: " + rouleauStart.inertieX.toFixed(1));
					trace("roll to: " + (rollFrom + rouleauStart.inertieX).toFixed(1));
					trace("contact x: " + Math.floor(contactPoint));
					trace("rouleau x: " + Math.floor(rouleauStart.x));
				}*/
				
				
			} else // triggered papyrus, must stop touleau start from moving
			{
				rouleauStart.x = rouleauStart.previousX;
				rouleauStart.spriteRouleau.frame = 0;
			}
			
			// update rouleauEnd
			if (rouleauEnd != null) 
			{
				rouleauEnd.spriteRouleau.rate = FP.scaleClamp(player.velocity.x, 0, 2, 0, 1) * FP.frameRate * FP.elapsed;
				rouleauEnd.x = Math.max((player.x + player.grandChild.width/2),
					rouleauStart.x, rouleauEnd.previousX);
				
				// update the width of the text underlay
				stretchPapyrus();
			}
	
		}
		
		/**
		 * Update the width of the papyrus to match distance between rouleau
		 */
		private function stretchPapyrus():void
		{
				// update text underlay by stretching the rectangle
				var width:Number = rouleauEnd.x - rouleauStart.x;// + rouleauEnd.spriteRouleau.width / 2;
				papyrus.rectWidth = width;
				
				//trace("rouleau w: " + rouleauEnd.spriteRouleau.width); returns 20
				//trace("papyrus w: " + papyrus.rectWidth);
				//trace("rouleauEnd.x - rouleauStart.x: " + (rouleauEnd.x - rouleauStart.x).toFixed(1));
		}
		
		/**
		 * Game END
		 */
		private function callCredits():void
		{
			if (false == _creditsCalled) 
			{
				var playCredits:Credits = new Credits();
				_creditsCalled = true;
				trace("call credits");
			}
		}
		
		/**
		 * Fade in the end music when grand child starts to disappear
		 */
		public function fadeInEndMusic():void
		{	
			creditMusic = new CreditMusic();
			add(creditMusic);
			creditMusic.musicEnd.play(0);
			creditMusic.fadeMusicIn.fadeTo(1, 2, Ease.sineIn);
			trace("fadeInEndMusic() called");
		}
		
		/**
		 * Fade out the end music when players hits return. This will also restart the game
		 * via the fader's callback function
		 */
		public function fadeOutEndMusic():void
		{
			creditMusic.fadeMusicOut.fadeTo(0, 2, Ease.sineOut);
			trace("fadeOutEndMusic() called");
		}
		
		/**
		 * adjust the framerates of the background animations based on player speed
		 */
		private function setAnimationSpeed():void
		{
			// first map player velocity to framerate
			var rate:Number = FP.scaleClamp(Math.max(Math.abs(player.velocity.x), Math.abs(player.velocity.y)), 0, 4, 0, 1);	
			
			for each (var animation:Animation in animationList)
			{
				
				// stop animations when player leaves world
				if (playerGoneAWOL || player.accouche) 
				{
					animation.spriteName.rate = 0;
				} else 
				{
					if (animation.animType==1) 
					{
						animation.playLooping();
						animation.spriteName.rate = rate * FP.frameRate * FP.elapsed;	
						
					} else if((animation.x - player.x) < animation.triggerDistance && !animation.playedOnce)
					{
						//trace("anim x: " + animation.x);
						//trace("player x: " + player.x);
						//trace("trigger distance: " + animation.triggerDistance);
						animation.playOnce();
						animation.playedOnce = true;
					}
				}
			}
		}
		
		/**
		 * Clean-up animations that have moved off the edge of the camera
		 */
		private function removeAnimations():void
		{	
			for (var m:int = 0; m < animationList.length; m++)
			{
				var value:Animation = animationList[m];
				
				// remove animations that are 600 pixels behind camera position
				if (value.x < (FP.camera.x - value.spriteName.width)) 
				{
					animationList.splice(m, 1);
					FP.world.remove(value);	
					m--;
				}
			}	
		}
		
		/**
		 * Clean-up backgrounds that have moved off the edge of the camera
		 */
		private function removeBackgrounds():void
		{	
			for (var bg:int = 0; bg < backgroundList.length; bg++)
			{
				var value:Background = backgroundList[bg];
				
				// remove animations that are 3990 pixels behind camera position
				if (value.x < (FP.camera.x - 3990)) 
				{
					var bgrnd:Vector.<Background> = backgroundList.splice(bg, 1);
					FP.world.remove(value);	
					bg--;
					trace("background removed at x: " + bgrnd[0].x);
					trace("bg list length: " + backgroundList.length);
				}
			}	
		}
		 
		/**
		 * update all the debug overlay info.
		 */
		public function updateDebugText():void
		{
			// draw debug information on screen
			var timer:Number;
			switch (player.state) 
			{
				case "father":
					timer = player.timeFatherToDeath.remaining;
					break;
				case "childAlive":
					timer = player.timeFatherToDeath.remaining;
					break;	
				case "child":
					timer = player.timeToGrandChild.remaining;
					break;
				case "grandChild":
					timer = player.timeGrandChildToEnd.remaining;
					break;
				
			}
			
			var father_var:String = "Red - Vb: " + Number(player.pathBaseSpeed[0]).toFixed(2) + " d: " + Number(player.pathDistance[0]).toFixed(2) + " ratr: " + Number(player.pathDistToTotalRatio[0]).toFixed(2) + " Vr: " + Number(player.pathMaxVel[0]).toFixed(2) + "\n"
									+"Green - Vb: " + Number(player.pathBaseSpeed[1]).toFixed(2) + " d: " + Number(player.pathDistance[1]).toFixed(2) +" ratv: " + Number(player.pathDistToTotalRatio[1]).toFixed(2) + " Vv: " + Number(player.pathMaxVel[1]).toFixed(2) + "\n"
									+"Blue - Vb: " + Number(player.pathBaseSpeed[2]).toFixed(2) + " d: " + Number(player.pathDistance[2]).toFixed(2) +" ratb: " + Number(player.pathDistToTotalRatio[2]).toFixed(2) + " Vb: " + Number(player.pathMaxVel[2]).toFixed(2) + "\n"
									+"Timer: " + Math.floor(timer) + " State: " + player.state.toUpperCase() +"\n"//+ " Row: " + player.row + " Col: " + player.col 
									+"modele de vitesse: " + player.typeVitesse[player.currentPathIndex] + "\n"
									+"Vinstantanée: " + Number(player.pathInstantVel[player.currentPathIndex]).toFixed(2) + " Vmax(des 3 path): " + Number(player.pathFastest).toFixed(2) + "\n"
									+ "CamX: " + FP.camera.x + " playerX: " + int(player.x);
									
			debugText.text = father_var;
			debugText.size = 12;
			debugHUD.x = FP.camera.x + 5;
			debugHUD.y = FP.camera.y + 5;

			//trace(debugText.text);
			if (LoadXmlData.DEBUG==true) 
			{
				debugHUD.graphic = debugText;
				debugHUD.layer = 0;
			}
			
			//temp position for overlay timer
			_overlay.updateTimer(Math.floor(timer));
		}
		
		/**
		 * Makes the camera follow the player object.
		 */
		private function cameraFollow():void
		{
			// make camera follow the player
			FP.point.x = FP.camera.x - targetX;
			FP.point.y = FP.camera.y - targetY;
			var dist:Number = FP.point.length;
			if (dist > FOLLOW_TRAIL) dist = FOLLOW_TRAIL;
			FP.point.normalize(dist * FOLLOW_RATE);
			FP.camera.x = int(targetX + FP.point.x);
			FP.camera.y = int(targetY + FP.point.y);
			
			// keep camera in room bounds
			
			FP.camera.x = FP.clamp(FP.camera.x, 0, worldWidth - FP.width);
			FP.camera.y = FP.clamp(FP.camera.y, 0, worldHeight - FP.height);
		}
		
		/**
		 * Getter functions used to get the position to place the camera when following the player.
		 */
		private function get targetX():Number 
		{
			if (_rouleauTriggered) 
			{
				// the higher the value
				// the more offset to the right the player will be
				return player.x - _cameraPan.value;
			} else	return player.x - FP.width / 2; 
			
		}
		
		private function get targetY():Number { return player.y - FP.height / 2; }
		
	} // end class

} // end package