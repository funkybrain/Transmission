package game 
{
	import net.flashpunk.Sfx;
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
	import net.flashpunk.Entity;
	import net.flashpunk.FP;
	import net.flashpunk.graphics.Anim;
	import net.flashpunk.graphics.Text;
	import net.flashpunk.tweens.misc.Alarm;
	import net.flashpunk.tweens.misc.NumTween;
	import net.flashpunk.utils.Ease;
	import flash.geom.Point;
	
	public class Game extends World
	{
		
		/**
		 * Levels
		 */
		public var level_1:Level;
		
		/**
		 * Fonts.
		 */
		[Embed(source = '../../assets/fonts/arial.ttf', fontFamily = 'Arial')] private static const FNT_ARIAL:Class;
		
		/**
		 * Camera following information.
		 */
		public const FOLLOW_TRAIL:Number = 50;
		public const FOLLOW_RATE:Number = .9;
		public var levelWidth:uint;
		public var levelHeight:uint;
				
		/**
		 * class properties used as object references.
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
		
		public var playerMoving:Boolean = false;
		public var vectorZero:Point = new Point();
		
		public var robotChildIsAlive:Boolean = false;
		public var robotFatherIsAlive:Boolean = false;
		
		// store ratio in easy to manipulate variables
		public var r:Number; 
		public var v:Number; 
		public var b:Number;
		public var maxRatio:Number;
		public var minRatio:Number;
		
		// List<Animation> to store background animations
		public var animationList:Vector.<Animation> = new Vector.<Animation>();
		
		/**
		 * Special effects and Tweens
		 */
		public var rightShutter:Shutter = new Shutter(800,0);
		public var shutterSpring:NumTween = new NumTween();
		private var _lastShutterPosH:Number = FP.camera.x + FP.screen.width / 2;
		private var _shutterX:int;
		private var _shutterY:int;

		/**
		 * Constructor.
		 */
		public function Game() 
		{
			// create first level
			level_1 = new Level();
			
			// set intial camera clamp value to level width/height
			levelWidth = level_1.width;
			levelHeight = level_1.height;
			
			// add level objects to world
			level_1.addObjectsToWorld(this)
			
			// add level animations to world and retrieve List<Animation>
			animationList = level_1.addBackgroundAnimationsToWorld(this);
			
			// add player to world
			player = level_1.addPlayerToWorld(this);
			
			// add debug hud to world
			debug = new Debug();
			debugHUD = new Entity();
			debugHUD.x = 10;
			debugHUD.y = 10;
			add(debugHUD);
			
			debugText = new Text("hello", 10, 10, 400, 50);
			debugText.font = "Arial";
			
			//set all transmission timer alarms (one-shot alarms)
			player.timeToChild = new Alarm(TIMER_CHILD, onTimeToChild, 2);
			player.addTween(player.timeToChild, true); // add and start alarm
			
			player.timeFatherToChild = new Alarm(TIMER_FATHERTOCHILD, onTimeFatherToChild, 2);
			player.addTween(player.timeFatherToChild, false); // add but don't start yet!
			
			player.timeFatherToDeath = new Alarm(TIMER_FATHERTODEATH, onTimeFatherToDeath, 2);
			player.addTween(player.timeFatherToDeath, false); // add but don't start yet!
			
			player.timeToGrandChild = new Alarm(TIMER_CHILDTOGRANDCHILD, onTimeToGrandChild, 2);
			player.addTween(player.timeToGrandChild, false); // add but don't start yet!
			
			player.timeGrandChildToEnd = new Alarm(TIMER_GRANDCHILDTOEND, onTimeToEnd, 2);
			player.addTween(player.timeGrandChildToEnd, false); // add but don't start yet!
			
			player.timers.push(player.timeToChild, player.timeFatherToChild, player.timeFatherToDeath,
				player.timeToGrandChild, player.timeGrandChildToEnd);
			
			// refresh screen color
			FP.screen.color = 0x808080;
			
			//add shutters to main window
			add(rightShutter);
			addTween(shutterSpring);
			
		} // end constructor
		
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
			remove(robotFather);
			trace("oh, shit, father just went awol...");
		}
		
		/**
		 * Transmit father to child
		 * player now controls child and father becomes a robot
		 */
		public function onTimeFatherToChild():void
		{
			
			// add robot child
			robotFather = new Robot(player.x, player.y, "robotfather");
			robotFatherIsAlive = true;
			add(robotFather);
			
			//transport father to robot child position
			player.x = robotChild.x;
			player.y = robotChild.y;
			
			//remove robot child from game
			robotChildIsAlive == false;
			remove(robotChild);
			
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
			player.state = "grandChild";
			player.graphic = player.grandChild;
			player.timeGrandChildToEnd.start() // start final countdown to end
			// will check in update to start death sequence before end
		}
		
		/**
		 * Death of grandchild and game end
		 */
		public function onTimeToEnd():void
		{
			// move to end credit?
		}
		
		public function transmitFatherToChild():void
		{
			//BUG: Romain n'utilise plus des vb(pour chaque chemin) lors de la transmission dans le dernier proto. Normal?
			// store ratio in easy to manipulate variables
			/*var r:Number = player.pathDistToTotalRatio[0]; 
			var v:Number = player.pathDistToTotalRatio[1]; 
			var b:Number = player.pathDistToTotalRatio[2];*/
   
			// cas 1: un chemin à 100%
			if(r>=0.99 || v>=0.99 || b>=0.99) {
				for (var j:int = 0; j < 3; j++) {
					if(player.pathDistToTotalRatio[j]>=0.99) {
						player.pathBaseSpeed[j] = player.VB + 2 * player.CT_VB;
					} else {
						player.pathBaseSpeed[j] = player.VB - player.CT_VB;
					}
				}
			} 
			else if (r>=0.60 && r/3.0>=v && v>=b) { // cas 2: un chemin à 60%
				player.pathBaseSpeed[0] = player.VB + 1.5 * player.CT_VB;
				player.pathBaseSpeed[1] = player.VB - player.CT_VB;
				player.pathBaseSpeed[2] = player.VB - player.CT_VB;
				trace("Perseverance cas1");
			}
			else if (r>=0.60 && r/3.0>=b && b>=v) { // cas 2: un chemin à 60%
				player.pathBaseSpeed[0] = player.VB + 1.5 * player.CT_VB;
				player.pathBaseSpeed[1] = player.VB - player.CT_VB;
				player.pathBaseSpeed[2] = player.VB - player.CT_VB;
				trace("Perseverance cas1");
			}
			else if (v>=0.60 && v/3.0>=r && r>=b) { // cas 2: un chemin à 60%
				player.pathBaseSpeed[0] = player.VB - player.CT_VB;
				player.pathBaseSpeed[1] = player.VB + 1.5 * player.CT_VB;
				player.pathBaseSpeed[2] = player.VB - player.CT_VB;
				trace("Perseverance cas1");
			}
			else if (v>=0.60 && v/3.0>=b && b>=r) { // cas 2: un chemin à 60%
				player.pathBaseSpeed[0] = player.VB - player.CT_VB;
				player.pathBaseSpeed[1] = player.VB + 1.5 * player.CT_VB;
				player.pathBaseSpeed[2] = player.VB - player.CT_VB;
				trace("Perseverance cas1");
			}
			else if (b>=0.60 && b/3.0>=v && v>=r) { // cas 2: un chemin à 60%
				player.pathBaseSpeed[0] = player.VB - player.CT_VB;
				player.pathBaseSpeed[1] = player.VB - player.CT_VB;
				player.pathBaseSpeed[2] = player.VB + 1.5 * player.CT_VB;
				trace("Perseverance cas1");
			}
			else if (b>=0.60 && b/3.0>=r && r>=v) { // cas 2: un chemin à 60%
				player.pathBaseSpeed[0] = player.VB - player.CT_VB;
				player.pathBaseSpeed[1] = player.VB - player.CT_VB;
				player.pathBaseSpeed[2] = player.VB + 1.5 * player.CT_VB;
				trace("Perseverance cas1");
			}
			else if(r>=0.35 && r<=0.50 && v>0.20 && v<0.50 && b<0.20 && b<0.50) { // Cas 1 :Ouverture 
				player.pathBaseSpeed[0] = player.VB + 0.50 * player.CT_VB;
				player.pathBaseSpeed[1] = player.VB + 0.50 * player.CT_VB;
				player.pathBaseSpeed[2] = player.VB + 0.50 * player.CT_VB;
				trace("Ouverture cas1");
			}
			else if(v>=0.35 && v<=0.50 && r>0.20 && r<0.50 && b>0.20 && b<0.50) { // Cas 1 :Ouverture 
				player.pathBaseSpeed[0] = player.VB + 0.50 * player.CT_VB;
				player.pathBaseSpeed[1] = player.VB + 0.50 * player.CT_VB;
				player.pathBaseSpeed[2] = player.VB + 0.50 * player.CT_VB;
				trace("Ouverture cas1");
			} 
			else if(r>=0.35 && r<=0.50 && b>0.20 && b<0.50 && v>0.20 && v<0.50) { // Cas 1 :Ouverture 
				player.pathBaseSpeed[0] = player.VB + 0.50 * player.CT_VB;
				player.pathBaseSpeed[1] = player.VB + 0.50 * player.CT_VB;
				player.pathBaseSpeed[2] = player.VB + 0.50 * player.CT_VB;
				trace("Ouverture cas1");
			}
			else if(v>=0.35 && v<=0.50 && b>0.20 && b<0.50 && r>0.20 && r<0.50) { // Cas 1 :Ouverture 
				player.pathBaseSpeed[0] = player.VB + 0.50 * player.CT_VB;
				player.pathBaseSpeed[1] = player.VB + 0.50 * player.CT_VB;
				player.pathBaseSpeed[2] = player.VB + 0.50 * player.CT_VB;
				trace("Ouverture cas1");
			} 
			else if(b>=0.35 && b<=0.50 && v>0.20 && v<0.50 && r>0.20 && r<0.50) { // Cas 1 :Ouverture 
				player.pathBaseSpeed[0] = player.VB + 0.50 * player.CT_VB;
				player.pathBaseSpeed[1] = player.VB + 0.50 * player.CT_VB;
				player.pathBaseSpeed[2] = player.VB + 0.50 * player.CT_VB;
				trace("Ouverture cas1");
			} 
			else if(b>=0.35 && b<=0.50 && r>0.20 && r<0.50 && v>0.20 && v<0.50) { // Cas 1 :Ouverture 
				player.pathBaseSpeed[0] = player.VB + 0.50 * player.CT_VB;
				player.pathBaseSpeed[1] = player.VB + 0.50 * player.CT_VB;
				player.pathBaseSpeed[2] = player.VB + 0.50 * player.CT_VB;
				trace("Ouverture cas1");
			}		 
			else {
				trace("cas moyen!");
			}
      
			for (var i:int = 0; i < 3; i++) {
				trace("vitesse de base child: ("+ i + ") " + player.pathBaseSpeed[i]);
			}
		} 
		// end transmitFatherToChild()
		
		/**
		 * UPDATE LOOP FOR GAME
		 */
		override public function update():void 
		{
			// update entities
			super.update();
			
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
			player.sound.update();
			
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
			setAnimationSpeed();
		}
		
		/**
		 * RENDER LOOP FOR GAME
		 */
		override public function render():void 
		{
			super.render();
			debug.drawHitBox(player);
			debugHUD.render();
			debug.drawHitBoxOrigin(player);
		}
		
		/**
		 * Check state of player to see if timers and sound should be frozen/unfrozen
		 */
		public function checkTimers():void
		{
			// need to check alarm states
			// those only affect those that have already started
			
			if (playerMoving==false && player.velocity.equals(vectorZero)==false) 
			{
				playerMoving = true;
			}
			
			if (playerMoving==true && player.velocity.equals(vectorZero)==true) 
			{
				playerMoving = false;
			}
			
			for each (var timer:Alarm in player.timers) 
			{
				// freeze sound and timers
				if (timer.active == true)
				{
					if (playerMoving == false) 
					{
						timer.active = false;
					}
				}
				
				if (playerMoving == false) 
				{
					for each (var noiseOut:Sfx in player.sound.pathSound) 
					{
						if (noiseOut.playing) 
						{
							noiseOut.stop();	
						}	
					}
				}
				
				//unfreeze sound and timers
				if (timer.active == false)
				{
					if (playerMoving == true) 
					{
						timer.active = true;	
					}
				}
				
				if (playerMoving == true) 
				{
					for each (var noiseIn:Sfx in player.sound.pathSound ) 
					{
						if (!noiseIn.playing) 
						{
							noiseIn.resume();	
						}
							
					}
				}
			}
		}
		
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
		
		/**
		 * GrandChild Death
		 */
		public function checkGrandChildNearDeath():void
		{
			
			if (player.timeGrandChildToEnd.remaining <= 10 && player.deathImminent==false) 
			{
				startDeathSequence(10); // 10 seconds to death
				player.deathImminent = true;
			}
			
			if (player.timeGrandChildToEnd.remaining==0) 
			{
				//death is nigh
				//FP.screen.scale = 0.9;
			}
		}
		
		public function startDeathSequence(time:Number):void
		{
			//fade player sprite out
			player.fadeOut.tween(player.grandChild, "alpha", 0, time, Ease.backIn);
			player.addTween(player.fadeOut);
			player.fadeOut.start();
			
			// go to end credits
			// removeAll();
		}
		
		/**
		 * adjust the framerates of the background animatins based on player speed
		 */
		public function setAnimationSpeed():void
		{
			// first map player velocity to framerate
			var rate:Number = FP.scale(Math.max(Math.abs(player.velocity.x), Math.abs(player.velocity.y)), 0, 2, 0, 1.5);	
			//trace(player.velocity.x);
			
			//TODO smooth with time.elpased and/or tween
			for each (var value:Animation in animationList)
			{
				value.spriteName.rate = rate;
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
			
			var father_var:String = "Red - Vb: " + Number(player.pathBaseSpeed[0]).toFixed(2) + " d: " + Number(player.pathDistance[0]).toFixed(2) + " r: " + Number(player.pathDistToTotalRatio[0]).toFixed(2) + " V: " + Number(player.pathMaxVel[0]).toFixed(2) + "\n"
									+"Green - Vb: " + Number(player.pathBaseSpeed[1]).toFixed(2) + " d: " + Number(player.pathDistance[1]).toFixed(2) +" r: " + Number(player.pathDistToTotalRatio[1]).toFixed(2) + " V: " + Number(player.pathMaxVel[1]).toFixed(2) + "\n"
									+"Blue - Vb: " + Number(player.pathBaseSpeed[2]).toFixed(2) + " d: " + Number(player.pathDistance[2]).toFixed(2) +" r: " + Number(player.pathDistToTotalRatio[2]).toFixed(2) + " V: " + Number(player.pathMaxVel[2]).toFixed(2) + "\n"
									+"Timer: " + Math.floor(timer) + " State: " + player.state + " Row: " + player.row + " Col: " + player.col +"\n";
			debugText.text = father_var;
			debugText.size = 11;
			debugHUD.x = FP.camera.x + 10;
			debugHUD.y = FP.camera.y + 10;

			//trace(debugText.text);
			if (LoadXmlData.DEBUG==true) 
			{
				debugHUD.graphic = debugText;
			}
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
			
			FP.camera.x = FP.clamp(FP.camera.x, 0, levelWidth - FP.width);
			FP.camera.y = FP.clamp(FP.camera.y, 0, levelHeight - FP.height);
		}
		
		/**
		 * Getter functions used to get the position to place the camera when following the player.
		 */
		private function get targetX():Number { return player.x - FP.width / 2; }
		private function get targetY():Number { return player.y - FP.height / 2; }
		
	} // end class

} // end package