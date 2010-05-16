package rooms
{
	//import game.Background;
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
	import net.flashpunk.Entity;
	import net.flashpunk.FP;
	import net.flashpunk.graphics.Text;
	import net.flashpunk.tweens.misc.Alarm;
	
	public class Level extends LevelLoader
	{
		/**
		 * Level XML.
		 */
		[Embed(source = '../../level/Level3_thin.oel', mimeType = 'application/octet-stream')] private static const LEVEL:Class;
		
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
		public var sound:SoundManager;
		public var debugText:Text;
		public var debugHUD:Entity;

		/**
		 * Game (transmission) specific variables.
		 */
		public var data:LoadXmlData;
		 
		private var TIMER_CHILD:Number = LoadXmlData.timer_ToChild;
		private var TIMER_FATHERTOCHILD:Number = LoadXmlData.timer_FatherToChild;
		private var TIMER_CHILDTOGRANDCHILD:Number = LoadXmlData.timer_ChildToGrandChild;
		
		public var player:Player;
		public var child:Robot;
		public var grandChild:Robot;
		public var childIsAlive:Boolean = false;
		
		public var animatedTile:PathTile;
		public var pathTileList:Vector.<PathTile> = new Vector.<PathTile>(); // List<PathTile> to store animated tiles
		
		 
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
			
			//add SoundManager object to world
			//sound = new SoundManager();

			//add(new Particles);
			//add(new Background);

						
			//add player to world

			for each (var p:XML in level.objects[0].player)
			{
				player = new Player(p.@x, p.@y);
				add(player);
			}

			
			//set all transmission timer alarms (one-shot alarms)
			player.timeToChild = new Alarm(TIMER_CHILD, onTimeToChild, 2);
			player.addTween(player.timeToChild, true); // add and start alarm on instantiation
			
			player.timeFatherToChild = new Alarm(TIMER_FATHERTOCHILD, onTimeFatherToChild, 2);
			player.addTween(player.timeFatherToChild, false); // add but don't start yet!
			
			player.timeToGrandChild = new Alarm(TIMER_CHILDTOGRANDCHILD, onTimeToGrandChild, 2);
			player.addTween(player.timeToGrandChild, false); // add but don't start yet!
			
			// refresh screen color
			FP.screen.color = 0x808080;

		}
		
		/**
		 * Child appears with father
		 */
		public function onTimeToChild():void
		{
			player.state = "childAlive"; // child appears as a robot. Nothing transmitted yet.
			player.timeFatherToChild.start(); // start countdown to actual transmission to child			
			child = new Robot(player.x, player.y);
			add(child);
			
		}
		
		/**
		 * Transmit father to child
		 */
		public function onTimeFatherToChild():void
		{
			//remove robot child from game and transmit properties from father to child
			remove(child);
			transmitFatherToChild();
			player.state = "child";
			player.timeToGrandChild.start();
		}
		
		/**
		 * Transmit child to grandchild
		 */
		public function onTimeToGrandChild():void
		{
			player.state = "grandChild";
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
		 * Update the level.
		 */
		override public function update():void 
		{
			// update entities
			super.update();
			
			// update debug text
			updateDebugText();
			
			//check if a new animated tile needs to be placed where player has walked
			var shiftX:Number, shiftY:Number; // need to locate the center of the entity
			shiftX = player.x + player.avatar.width / 2;
			shiftY = player.y + player.avatar.height / 2;
			addNewTile(shiftX, shiftY, 30); //TODO 30 is the grid step (move to property please!)

			
			//update SoundManager - required so the tweens actually get updated
			//sound.update();
			
			// if son is aliiven follow father
			if (childIsAlive) 
			{
				// follow father for a certain amount of tiime then disappear
				// upon disappearence, transmit values to father, which then becomes son
			}
			
			// camera following
			cameraFollow();
			
			//trace(player.state);
			
		}
		
		override public function render():void 
		{
			super.render();
			debug.drawHitBox(player);
			debugHUD.render();
		}
		
		//BUG why is first tile always red?
		public function addNewTile(_x:int, _y:int, _step:int ):void
		{
			// convert x,y into row, col
			var row:int, col:int, tileExists:Boolean=false;
			col = Math.floor(_x / _step);
			row = Math.floor(_y / _step);
			
			// loop through vector to see if a path of index (row,col) already exists
			for each (var value:PathTile in pathTileList)
			{
				if (value.row==row && value.col == col) 
				{
					tileExists = true;
					break;
				}				
			}
			
			if (tileExists==false) 
			{
				// add new animated tile to Vector and Level
				var index:int = pathTileList.push(new PathTile(col, row, 30, player.pathIndex)); //TODO ditto: don't hardwire step
				add(pathTileList[index-1]);
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
									+"Timer: " + Math.floor(timer) + " state: " + player.state +"\n";
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