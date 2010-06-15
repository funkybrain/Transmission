package game 
{
	import net.flashpunk.graphics.Canvas;
	import net.flashpunk.graphics.Spritemap;
	import net.flashpunk.Sfx;
	import net.flashpunk.tweens.misc.VarTween;
	import net.flashpunk.tweens.sound.SfxFader;
	import net.flashpunk.tweens.sound.Fader;
	import net.flashpunk.World;
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
	import game.Outro;
	import net.flashpunk.Entity;
	import net.flashpunk.FP;
	import net.flashpunk.graphics.Anim;
	import net.flashpunk.graphics.Text;
	import net.flashpunk.tweens.misc.Alarm;
	import net.flashpunk.tweens.misc.NumTween;
	import net.flashpunk.utils.Ease;
	import net.flashpunk.utils.Draw;
	import flash.geom.Point;
	
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
		 
		private var TIMER_CHILD:Number = LoadXmlData.timer_ToChild;
		//private var TIMER_FATHERTOCHILD:Number = LoadXmlData.timer_FatherToChild;
		private var TIMER_FATHERTODEATH:Number = LoadXmlData.timer_FatherToDeath;
		private var TIMER_CHILDTOGRANDCHILD:Number = LoadXmlData.timer_ChildToGrandChild;
		private var TIMER_GRANDCHILDTOEND:Number = LoadXmlData.timer_GrandChildToEnd;
		
		public var player:Player;
	
		public var vectorZero:Point = new Point();
		
		private var _lifeTimer:GameOverlay;
		
		// store ratio in easy to manipulate variables
		public var ratioRouge:Number; 
		public var ratioVert:Number; 
		public var ratioBleu:Number;
		private var _maxPathRatio:Number;
		private var _minPathRatio:Number;
		
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
		private var _shutterRightX:int;
		private var _shutterRightY:int;
		
		private var _shutterUp:Shutter;
		private var _shutterUpX:int;
		private var _shutterUpY:int;
		
		private var _shutterDown:Shutter;
		private var _shutterDownX:int;
		private var _shutterDownY:int;
		
		// Fade in screen
		private var _fadeInCurtain:Curtain;
		private var _fadeOutCurtain:Curtain;
		
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
		private var _outroCalled:Boolean = false;
		private var _masterFaderComplete:Boolean = true;
		private var _levelTwoAdded:Boolean = false;
		private var _rouleauTriggered:Boolean = false;
		private var _inContact:Boolean = false;
		

		public var playerGoneAWOL:Boolean = false;
		public var grandChildDying:Boolean = false;
		
		

		/**
		 * Epitaphe
		 */ 
		public var finalWords:Epitaphe;

		
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
			
			//set all transmission timer alarms (one-shot alarms)
			player.timeToChild = new Alarm(TIMER_CHILD, onTimeToChild, 2);
			player.addTween(player.timeToChild, true); // add and start alarm
			
			// don't need this anymore
			//player.timeFatherToChild = new Alarm(TIMER_FATHERTOCHILD, onTimeFatherToChild, 2);
			//player.addTween(player.timeFatherToChild, false); // add but don't start yet!
			
			player.timeFatherToDeath = new Alarm(TIMER_FATHERTODEATH, onTimeFatherToDeath, 2);
			player.addTween(player.timeFatherToDeath, true); // add and start alarm
			
			player.timeToGrandChild = new Alarm(TIMER_CHILDTOGRANDCHILD, onTimeToGrandChild, 2);
			player.addTween(player.timeToGrandChild, false); // add but don't start yet!
			
			player.timeGrandChildToEnd = new Alarm(TIMER_GRANDCHILDTOEND, onTimeGrandChildToEnd, 2);
			player.addTween(player.timeGrandChildToEnd, false); // add but don't start yet!
			
			player.timers.push(player.timeToChild, player.timeFatherToDeath,
				player.timeToGrandChild, player.timeGrandChildToEnd);
			
			// refresh screen color
			FP.screen.color = 0x808080;
			
			// fade game in
			fadeCurtainIn();

			// add game overlay
			_lifeTimer = new GameOverlay();
			add(_lifeTimer);
			
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
			_shutterRight = new Shutter(400, 0, "right");
			_shutterDown = new Shutter(0, 240, "down");
			_shutterUp = new Shutter(0, 0, "up");
			
			addList(_shutterDown, _shutterRight, _shutterUp);
		}
		
		/**
		 * Child appears with father
		 */
		public function onTimeToChild():void
		{
			// child appears as a robot. Nothing transmitted yet.
			player.state = "childAlive";

			// remove control from player
			player.hasControl = false;
			
			// swap father sprite for child appear sprite
			player.graphic = player.childAppear;
			player.childAppear.play("appear");
			
		}
		
		/**
		 * Make father disapear and child appear
		 */
		public function onTimeFatherToDeath():void
		{
			// trigger the father death sequence
			player.fatherDeathSequence();
			
			//transmit properties from father to child
			transmitFatherToChild();
			

			
		}
		
	
		
		/**
		 * Transmit child to grandchild
		 */
		public function onTimeToGrandChild():void
		{
			// trigger the daughter death sequence
			player.daughterDeathSequence();

			// transmit properties
			transmitFatherToChild();
		}
		
		/**
		 * Death of grandchild and game end
		 */
		public function onTimeGrandChildToEnd():void
		{
						
			trace("grandchild is dead");
			grandChildDying = false;

			// see if this helps kill the sounds
			playerGoneAWOL = true;
			
			// kill all sounds
			for each (var soundToKill:Sfx in player.sound.pathSound) 
			{
				if (soundToKill.playing) 
				{

					soundToKill.stop();
				}
			}
			
			
			// remove player from world
			removeList(player.sound, player);
			

			// send Outro
			_fadeOutCurtain = new Curtain(FP.width + 10, FP.height, "out");
			_fadeOutCurtain.x = FP.camera.x;
			_fadeOutCurtain.y = FP.camera.y;
			add(_fadeOutCurtain);
			trace("fade out");
		}
		
		
		/**
		 * Calculs de transmission
		 */
		public function transmitFatherToChild():void
		{
		
			var ratx:Number = Math.max(ratioRouge, ratioVert, ratioBleu); // ratio du chemin le plus parcouru
			var ratz:Number = Math.min(ratioRouge, ratioVert, ratioBleu); // ratio du chemin le moins parcouru
			var classement:Array = player.pathDistToTotalRatio.sort(Array.RETURNINDEXEDARRAY); // will return in ascending order
			
			// debug stuff
			for (var h:int = 0; h < 3; h++) 
			{
				trace("classement: " + classement[h]);
				switch (h) 
				{
					case 0:
						trace("ratio z: " + player.pathDistToTotalRatio[classement[h]]);
						break;
					case 1:
						trace("ratio y: " + player.pathDistToTotalRatio[classement[h]]);
						break;
					case 2:
						trace("ratio x: " + player.pathDistToTotalRatio[classement[h]]);
						break;
				}

			}
			
			// Modèle 1-a: 0.6<ratx<1 et 0=<ratz<0.2
			if (ratx > 0.6 && ratz < 0.2)
			{
				// set child special speed
				player.pathChildSpeed[classement[2]] = player.CT_VB + 0.8 * ratx;
				player.pathChildSpeed[classement[1]] = player.VB - 0.2 * ratx;
				player.pathChildSpeed[classement[0]] = player.VB - 0.2 * ratx;
				
				// reset base speed to VB
				for (var j:int = 0; j < player.pathBaseSpeed.length; j++) 
				{
					player.pathBaseSpeed[j] = player.VB;
				}
				player.transmitModel = 1;
				trace("Modèle 1a");
			} 
			// Modèle 1-b: 0.43=<ratx=<0.6 et 0=<ratz<0.15
			else if (ratx >= 0.43 && ratx <= 0.6 && ratz <= 0.15)
			{
				// set child special speed
				player.pathChildSpeed[classement[2]] = player.CT_VB + 0.6 * ratx;
				player.pathChildSpeed[classement[1]] = player.VB;
				player.pathChildSpeed[classement[0]] = player.VB;
				// reset base speed to VB
				for (var m:int = 0; m < player.pathBaseSpeed.length; m++) 
				{
					player.pathBaseSpeed[m] = player.VB;
				}
				trace("Modèle 1b");
				player.transmitModel = 1;
			}
			// Modèle 2: 0.34=<ratx=<0.6 et 0.15=<ratz<0.33
			else if (ratx >= 0.34 && ratx <= 0.6 && ratz >= 0.15 && ratz <= 0.33)
			{ 
				// set child special speed
				player.pathChildSpeed[classement[2]] = player.VB;
				player.pathChildSpeed[classement[1]] = player.VB;
				player.pathChildSpeed[classement[0]] = player.VB;
				// reset base speed to VB
				for (var k:int = 0; k < player.pathBaseSpeed.length; k++) 
				{
					player.pathBaseSpeed[k] = player.VB;
				}
				player.transmitModel = 2;
				trace("Modèle 2");
			}
			else
			{
				trace("cas moyen!");
			}
      
			for (var i:int = 0; i < 3; i++) {
				trace("nouvelle VB: ("+ i + ") " + player.pathChildSpeed[i]);
			}
			
			// remettre toues les distances à zero
			for (var s:int = 0; s < 3; s++) 
			{
				//store distances and velocities
				if (player.state == "father" || player.state == "childAlive") 
				{
					player.fatherStoredDistances[s] = player.pathDistance[s];
					player.fatherStoredVelocities[s] = player.pathMaxVel[s];
				} else	{
					player.childStoredDistances[s] = player.pathDistance[s];
					player.childStoredVelocities[s] = player.pathMaxVel[s];
				}
	
				//reset distances to zero
				player.pathDistance[s] = 0;
			}
			
			
			var sortpaths:Array = new Array();
			var sortspeeds:Array = new Array();
			
			// transmettre les index de chemin pour calcul de vitesse _type3
			if (player.state == "father" || player.state == "childAlive") 
			{
				// calculate all the stuff needed to set-up _type3 velocities
				sortpaths = player.fatherStoredDistances.sort(Array.RETURNINDEXEDARRAY | Array.DESCENDING | Array.NUMERIC); // sort in descending order
				player.Dxtotale = player.fatherStoredDistances[sortpaths[0]]; //store the highest value DxTotal
				
				sortspeeds = player.fatherStoredVelocities.sort(Array.RETURNINDEXEDARRAY | Array.DESCENDING | Array.NUMERIC); // sort in descending order
				// sortspeeds[1] and [2] are the slowest paths of the father at transmission
				
				player.transmitIndexY = sortspeeds[1];
				player.transmitIndexZ = sortspeeds[2];

				trace("pere -> fils");
				trace("chemin le plus emprunté: " + sortpaths[0]);
				trace("Dxtotale: " + Number(player.Dxtotale).toFixed(1));
				trace("chemins les plus lents: " + player.transmitIndexY + " " + player.transmitIndexZ);
				trace("distance sur ces chemins: " + Number(player.fatherStoredDistances[sortpaths[1]]).toFixed(1) + " " + Number(player.fatherStoredDistances[sortpaths[2]]).toFixed(1));
				

			} else {
				
				// calculate all the stuff needed to set-up _type3 velocities
				sortpaths = player.childStoredDistances.sort(Array.RETURNINDEXEDARRAY | Array.DESCENDING | Array.NUMERIC); // sort in descending order
				player.Dxtotale = player.childStoredDistances[sortpaths[0]]; //store the highest value DxTotal
			
				
				sortspeeds= player.childStoredVelocities.sort(Array.RETURNINDEXEDARRAY | Array.DESCENDING | Array.NUMERIC); // sort in descending order
				// sortspeeds[1] and [2] are the slowest paths of the father at transmission
				
				player.transmitIndexY = sortspeeds[1];
				player.transmitIndexZ = sortspeeds[2];

				trace("fils -> petit_fils");
				trace("chemin le plus emprunté: " + sortpaths[0]);
				trace("Dxtotale: " + Number(player.Dxtotale).toFixed(1));
				trace("chemins les plus lents: " + player.transmitIndexY + " " + player.transmitIndexZ);
				trace("distance sur ces chemins: " + Number(player.childStoredDistances[sortpaths[1]]).toFixed(1) + " " + Number(player.childStoredDistances[sortpaths[2]]).toFixed(1));

			}
			
			// reset _type3 for next transmission
			player.type3 = false;
			
			
		} 
		// end transmitFatherToChild()
		
		
		
/*		public function transmitChildToGrandChild():void // may not need this
		{
			// transmition formulas here
			
			remettre toues les distances à zero
			for (var s:int = 0; s < player.pathDistance.length; s++) 
			{
				//store father distances
				player.childStoredDistances[s] = player.pathDistance[s];
				//reset distances to zero
				player.pathDistance[s] = 0;
			}
		}*/
		// end transmitChildToGrandChild()
		
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
			_updateRouleauPositions();
			
			// unravel final words
			if (null != finalWords) 
			{
				// update the text length of final words
				_updateFinalWords();
			}
			
			// update path ratios
			_calculatePathRatios();

			
			// update shutter positions
			updateShutters();
			
			
			//test to see if we're near game end
			checkGrandChildNearDeath();
			
			// update debug text
			updateDebugText();
			
			//update SoundManager - required so the tweens actually get updated
			//player.sound.update();
			
			// if son is alive follow father
			/*if (robotChildIsAlive) 
			{
				robotChild.x = player.moveHistory[0].x;
				robotChild.y = player.moveHistory[0].y;
				if (player.velocity.x!=0 || player.velocity.y!=0) 
				{
					robotChild.robotChild.play("walk");
				} else robotChild.robotChild.setFrame(0);
			}*/
			
			// camera following
			cameraFollow();
			
			
			// freeze or unfreeze timers and sounds
			checkTimers();
			
			
			//set backgound animation framerates based on player speed
			_setAnimationSpeed();
			
			// if final fade out is finished, send-in Outro
			if (null != _fadeOutCurtain && _fadeOutCurtain.complete) 
			{
				_leaveGame();
			}
			
			
			
			// test to see if next level needs to be imported
			if (FP.camera.x > (level_1.width - FP.width - 100) && !_levelTwoAdded) 
			{
				_importNextLevel();
				_levelTwoAdded = true;
				trace("import level2");
			}
			
			// clean-up animation and background list to save on memory
			_removeAnimations();
			_removeBackgrounds();
			
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
					_startFinalWords();
			}

			// debug
			if (null != _cameraPan && _cameraPan.active)
			{
				//trace("cam pan: " + _cameraPan.value);
			}
			
			
			// fade volume out when grandchild is dying
			if (grandChildDying) 
			{
				//FP.volume = masterfader.value;
				//set the volume to the alpha value of the grandChild as it fades out
				FP.volume = player.grandChild.alpha;
				//trace("vol: " + FP.volume);
			}
		}
		// end Game UPDATE LOOP
		
		/**
		 * Calculate the path ratios
		 */
		private function _calculatePathRatios():void
		{
			ratioRouge = player.pathDistToTotalRatio[0]; 
			ratioVert = player.pathDistToTotalRatio[1]; 
			ratioBleu = player.pathDistToTotalRatio[2];
			_maxPathRatio = Math.max(ratioRouge,ratioVert,ratioBleu);
			_minPathRatio = Math.min(ratioRouge,ratioVert,ratioBleu);
		}
		
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
		private function _importNextLevel():void
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
			/* RIGHT shutter */
			var shutterRightClosed:Number = FP.camera.x + FP.screen.width / 2;					
			var shutterRightOpen:Number = FP.camera.x + FP.screen.width;
			var shutterRightTarget:Number = FP.scaleClamp(_maxPathRatio, 0.33, 0.99, shutterRightClosed, shutterRightOpen);
			
			
			if (player.totaldistance >= 1000) 
			{
				_shutterRight.x = shutterRightTarget;
			} else _shutterRight.x = shutterRightClosed;
			
			_shutterRight.y = 0;
			
			/* UP shutter */
			var shutterUpClosed:Number = 0;					
			var shutterUpOpen:Number = -FP.screen.height/2;
			var shutterUpTarget:Number = FP.scaleClamp(_minPathRatio, 0, 0.33, shutterUpClosed, shutterUpOpen);

			if (player.totaldistance >= 1000) 
			{
				_shutterUp.y = shutterUpTarget;
			}
			
			_shutterUp.x = FP.camera.x;
			
			/* DOWN shutter */
			var shutterDownClosed:Number = FP.screen.height / 2;					
			var shutterDownOpen:Number = FP.screen.height;
			var shutterDownTarget:Number = FP.scaleClamp(_minPathRatio, 0, 0.33, shutterDownClosed, shutterDownOpen);			
			
			if (player.totaldistance >= 1000) 
			{
				_shutterDown.y = shutterDownTarget;
			}
			
			_shutterDown.x = FP.camera.x;
			
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
			grandChildDying = true;

		}
		
		/**
		 * Generate final words
		 */
		
		private function _startFinalWords():void
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
		private function _updateFinalWords():void
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
		private function _updateRouleauPositions():void
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
				_stretchPapyrus();
			}
	
		}
		
		/**
		 * Update the width of the papyrus to match distance between rouleau
		 */
		private function _stretchPapyrus():void
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
		private function _leaveGame():void
		{
			if (false == _outroCalled) 
			{
				trace("call credits");
				
				
				var playCredits:Credits = new Credits();
				_outroCalled = true;
				
				// remove all entities from world
				FP.world.removeAll();
				
				//reset vol to play credits
				FP.volume = 0.8;
			}
		}
		
		/**
		 * adjust the framerates of the background animations based on player speed
		 */
		private function _setAnimationSpeed():void
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
		private function _removeAnimations():void
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
		private function _removeBackgrounds():void
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
			_lifeTimer.updateTimer(Math.floor(timer));
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