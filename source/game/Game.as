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
		private var TIMER_FATHERTOCHILD:Number = LoadXmlData.timer_FatherToChild;
		private var TIMER_FATHERTODEATH:Number = LoadXmlData.timer_FatherToDeath;
		private var TIMER_CHILDTOGRANDCHILD:Number = LoadXmlData.timer_ChildToGrandChild;
		private var TIMER_GRANDCHILDTOEND:Number = LoadXmlData.timer_GrandChildToEnd;
		
		public var player:Player;
		public var robotChild:Robot;
		public var robotFather:Robot;
		
		public var robotFatherPath:FindPath;
	
		public var vectorZero:Point = new Point();
		
		private var _lifeTimer:GameOverlay;
		
		// store ratio in easy to manipulate variables
		public var r:Number; 
		public var v:Number; 
		public var b:Number;
		public var maxRatio:Number;
		public var minRatio:Number;
		
		// List<Animation> to store background animations
		public var animationList:Vector.<Animation> = new Vector.<Animation>();
		public var backgroundList:Vector.<Background> = new Vector.<Background>();
		
		
		/**
		 * Special effects and Tweens
		 */
		
		// Sound Tweens
		public var masterfader:NumTween;
		
		// Shutters 
		public var rightShutter:Shutter = new Shutter(800,0);
		public var shutterSpring:NumTween = new NumTween();
		private var _lastShutterPosH:Number = FP.camera.x + FP.screen.width / 2;
		private var _shutterX:int;
		private var _shutterY:int;
		
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
		
		/**
		 * Booleans
		 */
		private var _outroCalled:Boolean = false;
		private var _masterFaderComplete:Boolean = true;
		private var _levelTwoAdded:Boolean = false;
		private var _rouleauTriggered:Boolean = false;
		
		public var robotChildIsAlive:Boolean = false;
		public var robotFatherIsAlive:Boolean = false;
		public var playerGoneAWOL:Boolean = false;
		public var grandChildDying:Boolean = false;
		
		

		/**
		 * Epitaphe
		 */ 
		public var finalWords:Epitaphe;

		
		/**
		 * CONSTRUCTOR
		 */
		public function Game() 
		{
			// create first level
			level_1 = new Level(1, 0);
			
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
			
			player.timeFatherToChild = new Alarm(TIMER_FATHERTOCHILD, onTimeFatherToChild, 2);
			player.addTween(player.timeFatherToChild, false); // add but don't start yet!
			
			player.timeFatherToDeath = new Alarm(TIMER_FATHERTODEATH, onTimeFatherToDeath, 2);
			player.addTween(player.timeFatherToDeath, false); // add but don't start yet!
			
			player.timeToGrandChild = new Alarm(TIMER_CHILDTOGRANDCHILD, onTimeToGrandChild, 2);
			player.addTween(player.timeToGrandChild, false); // add but don't start yet!
			
			player.timeGrandChildToEnd = new Alarm(TIMER_GRANDCHILDTOEND, onTimeGrandChildToEnd, 2);
			player.addTween(player.timeGrandChildToEnd, false); // add but don't start yet!
			
			player.timers.push(player.timeToChild, player.timeFatherToChild, player.timeFatherToDeath,
				player.timeToGrandChild, player.timeGrandChildToEnd);
			
			// refresh screen color
			FP.screen.color = 0x808080;
			
			//add shutters to main window
			add(rightShutter);
			addTween(shutterSpring);
			
			// fade game in
			fadeCurtainIn();

			// add game overlay
			_lifeTimer = new GameOverlay();
			add(_lifeTimer);
			
			//TODO remove kill vol befor publish
			//FP.volume = 1;
						
		} // end constructor
		
		
		public function fadeCurtainIn():void
		{
			_fadeInCurtain = new Curtain(FP.width, FP.height, "in");
			add(_fadeInCurtain);
			trace("fade In");
		}
		
		/**
		 * Child appears with father
		 */
		public function onTimeToChild():void
		{
			// child appears as a robot. Nothing transmitted yet.
			player.state = "childAlive";
			robotChildIsAlive = true;
			
			// start countdown to actual transmission to child
			player.timeFatherToChild.start(); 			
			
			// start countdown to father death
			player.timeFatherToDeath.start();
			
			// add robot child
			robotChild = new Robot(player.x, player.y,"robotchild");
			add(robotChild);
			
		}
		
		/**
		 * Make father disapear
		 */
		public function onTimeFatherToDeath():void
		{
			//remove robot father from game
			robotFatherIsAlive == false;
			//BUG remove(robotFather);
			trace("oh, shit, father just went awol...");
		}
		
		/**
		 * Transmit father to child
		 * player now controls child and father becomes a robot
		 */
		public function onTimeFatherToChild():void
		{
			
			// add robot father
			robotFather = new Robot(player.x, player.y, "robotfather");
			robotFatherIsAlive = true;
			add(robotFather);
			
			// create path that robot father must follow
			//robotFatherPath = new FindPath();
			
			// create AI node graph
			generateAIGraph(robotFather.x, robotFather.y);
			
			//TODO need to make robotater follow ai pathfinding
			
			//TODO may need to create new player here to avoid this hellish bug
			//transport father to robot child position
			player.x = robotChild.x;
			player.y = robotChild.y;
			
			//remove robot child from game
			robotChildIsAlive = false;
			remove(robotChild);
			
			trace(player.state);
			
			//transmit properties from father to child
			transmitFatherToChild();
			
			//set player state to child
			player.state = "child";
			
			//change player graphic to that of child
			player.graphic = player.child;
			
			//start countdown to grandchild transmission
			player.timeToGrandChild.start();
		}
		
		/**
		 * Transmit child to grandchild
		 */
		public function onTimeToGrandChild():void
		{
			// trigger auto-accouchement
			player.graphic = player.autoAccouchement;
			player.autoAccouchement.play("push");
			player.accouche = true;
			
			// swap player sprite to grandchild
			// player.graphic = player.grandChild;
			// this is now handled by onAccoucheComplete event handler in Player class
			
			// start final countdown to end
			// will check in update to start death sequence before end
			player.timeGrandChildToEnd.start();
			
			
			// transmit properties
			transmitFatherToChild(); // use one method for both transmissions
			
			// change player state
			// player.state = "grandChild";

		}
		
		/**
		 * Death of grandchild and game end
		 */
		public function onTimeGrandChildToEnd():void
		{
						
			trace("grandchild is dead");

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
		 * AI calculations
		 */
		public function generateAIGraph(startX:int, startY:int):void
		{
			// generate the graph based on father start position
		}
		
		/**
		 * Calculs de transmission
		 */
		public function transmitFatherToChild():void
		{
		
			var ratx:Number = Math.max(r, v, b); // ratio du chemin le plus parcouru
			var ratz:Number = Math.min(r, v, b); // ratio du chemin le moins parcouru
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
				player.pathChildSpeed[classement[2]] = player.VB + 0.8 * ratx;
				player.pathChildSpeed[classement[1]] = player.VB - 0.2 * ratx;
				player.pathChildSpeed[classement[0]] = player.VB - 0.2 * ratx;
				
				// reset base speed to VB
				for (var j:int = 0; j < player.pathBaseSpeed.length; j++) 
				{
					player.pathBaseSpeed[j] = player.CT_VB;
				}
				player.transmitModel = 1;
				trace("Modèle 1a");
			} 
			// Modèle 1-b: 0.43=<ratx=<0.6 et 0=<ratz<0.15
			else if (ratx >= 0.43 && ratx <= 0.6 && ratz <= 0.15)
			{
				// set child special speed
				player.pathChildSpeed[classement[2]] = player.VB + 0.6 * ratx;
				player.pathChildSpeed[classement[1]] = player.VB;
				player.pathChildSpeed[classement[0]] = player.VB;
				// reset base speed to VB
				for (var m:int = 0; m < player.pathBaseSpeed.length; m++) 
				{
					player.pathBaseSpeed[m] = player.CT_VB;
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
					player.pathBaseSpeed[k] = player.CT_VB;
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
			r = player.pathDistToTotalRatio[0]; 
			v = player.pathDistToTotalRatio[1]; 
			b = player.pathDistToTotalRatio[2];
			maxRatio = Math.max(r,v,b);
			minRatio = Math.min(r,v,b);
			
			// update shutter positions
			if (player.x>FP.screen.width/2-10) 
			{
				updateShutters();
				
			}
			
			//test to see if we're near game end
			checkGrandChildNearDeath();
			
			// update debug text
			updateDebugText();
			
			//update SoundManager - required so the tweens actually get updated
			//player.sound.update();
			
			// if son is alive follow father
			if (robotChildIsAlive) 
			{
				robotChild.x = player.moveHistory[0].x;
				robotChild.y = player.moveHistory[0].y;
				if (player.velocity.x!=0 || player.velocity.y!=0) 
				{
					robotChild.robotChild.play("walk");
				} else robotChild.robotChild.setFrame(0);
			}
			
			// camera following
			cameraFollow();
			
			// freeze or unfreeze timers and sounds
			checkTimers();
			
			
			//set backgound animation framerates based on player speed
			_setAnimationSpeed();
			
			// if final fade out is finished, send-in Outro
			_leaveGame();
			
			
			// test to see if next level needs to be imported
			if (FP.camera.x > (level_1.width - FP.width - 100) && !_levelTwoAdded) 
			{
				_importNextLevel();
				_levelTwoAdded = true;
				trace("import level2");
			}
			
			// clean-up animation list to save on memory
			_removeAnimations();
			
			// check to see if player has triggered rouleau
			if (null != level_2 && player.x > rouleauTriggerX && !_rouleauTriggered) 
			{
					_rouleauTriggered = true;
					_startFinalWords();
			}
			
			// fade volume out when grandchild is dying
			if (grandChildDying) 
			{
				//FP.volume = masterfader.value;
				//set the volume to the alpha value of the grandChild as it fades out
				FP.volume = player.grandChild.alpha;
				trace("vol: " + FP.volume);
			}
		}
		// end Game UPDATE LOOP
		
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
			
			// get trigger for rouleau
			rouleauTriggerX = level_2.getTriggerPosition();
			trace("trigger X : " + rouleauTriggerX); 

			
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
			
			if (player.playerWasMoving==false && !player.velocity.equals(vectorZero)) 
			{
				player.playerMoving = true;				
			}
			
			if (player.playerWasMoving==true && player.velocity.equals(vectorZero)) 
			{
				player.playerMoving = false;				
			}
			
			for each (var timer:Alarm in player.timers) 
			{
				// freeze timers
				if (timer.active == true)
				{
					if (player.playerMoving == false) 
					{
						timer.active = false;
					}
				}
				
				
				
				//unfreeze timers
				if (timer.active == false)
				{
					if (player.playerMoving == true) 
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
			var xmin:Number = FP.camera.x + FP.screen.width / 2;					
			var xmax:Number = FP.camera.x + FP.screen.width;
			
			var xtarget:Number = FP.scaleClamp(maxRatio, 0.3, 0.9, xmin, xmax);
			
			/*if (shutterSpring.active==false && int(xtarget) != int(_lastShutterPosH)) 
			{
				shutterSpring.tween(_lastShutterPosH, xtarget, 3);					
				shutterSpring.start();
				trace("start tween shutter");
				trace("moving from: " + (_lastShutterPosH - FP.camera.x));
				trace("moving to: " + (xtarget - FP.camera.x));
				trace("speed: " + player.playerCeilingVelocity.length);
				
			}*/
			//BUG i don't think the tween is working, even though the xtarget position seems ok
			//_shutterX = shutterSpring.value;
			_shutterX = xtarget;
			_shutterY = FP.camera.y;

			rightShutter.x = _shutterX;
			rightShutter.y = _shutterY;
			
			// store current position for next loop
			_lastShutterPosH = rightShutter.x;
		}
		// end updateShutters()
		
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
			finalWords.x = rouleauStart.x + rouleauStart.spriteRouleau.width;
			add(finalWords);

			// add the second rouleau that unravels
			rouleauEnd = new Rouleau();
			rouleauEnd.spriteRouleau.color = 0xA7B6EC;
			rouleauEnd.x = rouleauStart.x + rouleauStart.spriteRouleau.width;
			add(rouleauEnd);
			
			// add underlying paper
			papyrus = new Papyrus((rouleauStart.x + rouleauStart.spriteRouleau.width), 0,
			(rouleauEnd.x - rouleauStart.x - rouleauEnd.spriteRouleau.width), FP.screen.height);
			papyrus.visible = false;
			add(papyrus);
			
		}
		
		
		/**
		 * unravel the words as player moves
		 */
		private function _updateFinalWords():void
		{
			// display one character every 30 pixels the player moves
			var wordslength:int = (player.x - rouleauTriggerX) / 30;
			//trace("wordslength: " + wordslength);
			finalWords.unravelFinalWord(wordslength);
		}
		
		
		/**
		 * Update rouleau positions and animations
		 */
		private function _updateRouleauPositions():void
		{
			if (rouleauStart != null && !_rouleauTriggered) 
			{
				// place rouleau
				rouleauStart.x = Math.max(rouleauStart.previousX, player.x + (player.graphic as Spritemap).width/2*(player.graphic as Spritemap).scale);
				// animate rouleau based on player speed
				if (!player.accouche) 
				{
					rouleauStart.spriteRouleau.rate = FP.scaleClamp(player.velocity.x, 0, 2, 0, 1) * FP.frameRate * FP.elapsed;
					
				} else rouleauStart.spriteRouleau.rate = 0;
				
			} else
			{
				rouleauStart.x = rouleauStart.previousX;
				rouleauStart.spriteRouleau.frame = 0;
			}
			
			if (rouleauEnd != null) 
			{
				rouleauEnd.spriteRouleau.rate = FP.scaleClamp(player.velocity.x, 0, 2, 0, 1) * FP.frameRate * FP.elapsed;
				rouleauEnd.x = Math.max(player.x + player.grandChild.width/2,
					rouleauStart.x + rouleauStart.spriteRouleau.width);
				
				// update text underlay
				papyrus.visible = true;
				papyrus.x = rouleauStart.x + rouleauStart.spriteRouleau.width;
				papyrus.width = rouleauEnd.x - rouleauStart.x - rouleauEnd.spriteRouleau.width;
			}
	
		}
		
		/**
		 * Game END
		 */
		private function _leaveGame():void
		{
			if (null != _fadeOutCurtain && true == _fadeOutCurtain.complete && false == _outroCalled) 
			{
				
				trace("call credits");
				// reset vol
				FP.volume = 1;
				trace("leaving game, volume: " + FP.volume);
				var playCredits:Credits = new Credits();
				_outroCalled = true;

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
						trace("anim x: " + animation.x);
						trace("player x: " + player.x);
						trace("trigger distance: " + animation.triggerDistance);
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
				if (value.x < (FP.camera.x - 600)) 
				{
					animationList.splice(m, 1);
					FP.world.remove(value);	
					m--;
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
					timer = player.timeToChild.remaining;
					break;
				case "childAlive":
					timer = player.timeFatherToChild.remaining;
					break;	
				case "child":
					timer = player.timeToGrandChild.remaining;
					break;
				case "grandChild":
					timer = player.timeGrandChildToEnd.remaining;
					break;
				
			}
			
			var father_var:String = "Red - Vb: " + Number(player.pathBaseSpeed[0]).toFixed(2) + " d: " + Number(player.pathDistance[0]).toFixed(2) + " r: " + Number(player.pathDistToTotalRatio[0]).toFixed(2) + " Vr: " + Number(player.pathMaxVel[0]).toFixed(2) + "\n"
									+"Green - Vb: " + Number(player.pathBaseSpeed[1]).toFixed(2) + " d: " + Number(player.pathDistance[1]).toFixed(2) +" r: " + Number(player.pathDistToTotalRatio[1]).toFixed(2) + " Vv: " + Number(player.pathMaxVel[1]).toFixed(2) + "\n"
									+"Blue - Vb: " + Number(player.pathBaseSpeed[2]).toFixed(2) + " d: " + Number(player.pathDistance[2]).toFixed(2) +" r: " + Number(player.pathDistToTotalRatio[2]).toFixed(2) + " Vb: " + Number(player.pathMaxVel[2]).toFixed(2) + "\n"
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
		private function get targetX():Number { return player.x - FP.width / 2; }
		private function get targetY():Number { return player.y - FP.height / 2; }
		
	} // end class

} // end package