package rooms
{
	//import game.Particles;
	
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
	import net.flashpunk.Entity;
	import net.flashpunk.FP;
	import net.flashpunk.graphics.Anim;
	import net.flashpunk.graphics.Text;
	import net.flashpunk.tweens.misc.Alarm;
	import net.flashpunk.utils.Ease;
	
	public class Level extends LevelLoader
	{
		/**
		 * Level XML.
		 */
		[Embed(source = '../../level/Level4_thin.oel', mimeType = 'application/octet-stream')] private static const LEVEL:Class;
		
		/**
		 * Fonts.
		 */
		[Embed(source = '../../assets/fonts/arial.ttf', fontFamily = 'Arial')] private static const FNT_ARIAL:Class;
		

		 
		/**
		 * Camera following information.
		 */
		public const FOLLOW_TRAIL:Number = 50;
		public const FOLLOW_RATE:Number = .9;
		
		/**
		 * Size of the level (so it knows where to keep the player + camera in).
		 */
		public var width:uint;
		public var height:uint;
		
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
		private var TIMER_CHILDTOGRANDCHILD:Number = LoadXmlData.timer_ChildToGrandChild;
		private var TIMER_GRANDCHILDTOEND:Number = LoadXmlData.timer_GrandChildToEnd;
		
		public var player:Player;
		public var child:Robot;
		public var robotChildIsAlive:Boolean = false;
		
		// List<Animation> to store background animations
		public var animationList:Vector.<Animation> = new Vector.<Animation>();
		
		/**
		 * Constructor.
		 */
		public function Level()
		{
			super(LEVEL);
			
			width = level.width;
			height = level.height;
			
			// add paths to world
			add(new PathRed(level));
			add(new PathBlue(level));
			add(new PathGreen(level));
			
			// add debug hud to world
			debug = new Debug();
			debugHUD = new Entity();
			debugHUD.x = 10;
			debugHUD.y = 10;
			add(debugHUD);
			
			debugText = new Text("hello", 10, 10, 400, 50);
			debugText.font = "Arial";
			


			//add(new Particles);
			
			add(new Background);

						
			//add player to world
			for each (var p:XML in level.objects[0].player)
			{
				player = new Player(p.@x, p.@y);
				add(player);
			}
			
			//add animations to world
			for each (var q:XML in level.animations.anim_man)
			{
				// add new animation to Vector and Level
				var index_one:int = animationList.push(new Animation(q.@x, q.@y, "man"));
				add(animationList[index_one-1]);
			}

			for each (var r:XML in level.animations.anim_rouage)
			{
				// add new animation to Vector and Level
				var index_two:int = animationList.push(new Animation(r.@x, r.@y, "rouage"));
				add(animationList[index_two-1]);
			}

			
			//set all transmission timer alarms (one-shot alarms)
			player.timeToChild = new Alarm(TIMER_CHILD, onTimeToChild, 2);
			player.addTween(player.timeToChild, true); // add and start alarm on instantiation
			
			player.timeFatherToChild = new Alarm(TIMER_FATHERTOCHILD, onTimeFatherToChild, 2);
			player.addTween(player.timeFatherToChild, false); // add but don't start yet!
			
			player.timeToGrandChild = new Alarm(TIMER_CHILDTOGRANDCHILD, onTimeToGrandChild, 2);
			player.addTween(player.timeToGrandChild, false); // add but don't start yet!
			
			player.timeGrandChildToEnd = new Alarm(TIMER_GRANDCHILDTOEND, onTimeToEnd, 2);
			player.addTween(player.timeGrandChildToEnd, false); // add but don't start yet!
			
			// refresh screen color
			FP.screen.color = 0x808080;

		}
		
		/**
		 * Child appears with father
		 */
		public function onTimeToChild():void
		{
			player.state = "childAlive"; // child appears as a robot. Nothing transmitted yet.
			robotChildIsAlive = true;
			player.timeFatherToChild.start(); // start countdown to actual transmission to child			
			child = new Robot(player.x, player.y);
			add(child);
			
		}
		
		/**
		 * Transmit father to child
		 */
		public function onTimeFatherToChild():void
		{
			//remove robot child from game
			robotChildIsAlive == false;
			remove(child);
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
			var r:Number = player.pathDistToTotalRatio[0]; 
			var v:Number = player.pathDistToTotalRatio[1]; 
			var b:Number = player.pathDistToTotalRatio[2];
   
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
			
			//test to see if we're near game end
			checkGrandChildNearDeath();
			
			// update debug text
			updateDebugText();
			
			//update SoundManager - required so the tweens actually get updated
			player.sound.update();
			
			// if son is alive follow father
			if (robotChildIsAlive) 
			{
				child.x = player.moveHistory[0].x;
				child.y = player.moveHistory[0].y;
				if (player.velocity.x!=0 || player.velocity.y!=0) 
				{
					child.robotSprite.play("walk");
				} else child.robotSprite.setFrame(0);
			}
			
			// camera following
			cameraFollow();
			
			//trace(player.state);
			
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
		 * GrandChild Death
		 */
		public function checkGrandChildNearDeath():void
		{
			
			if (player.timeGrandChildToEnd.remaining <= 10 && player.deathImminent==false) 
			{
				startDeathSequence(10); // 10 seconds to death
				player.deathImminent = true;
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
					timer = 0;
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
			debugHUD.graphic = debugText;
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
			FP.camera.x = FP.clamp(FP.camera.x, 0, width - FP.width);
			FP.camera.y = FP.clamp(FP.camera.y, 0, height - FP.height);
		}
		
		/**
		 * Getter functions used to get the position to place the camera when following the player.
		 */
		private function get targetX():Number { return player.x - FP.width / 2; }
		private function get targetY():Number { return player.y - FP.height / 2; }
	}
}