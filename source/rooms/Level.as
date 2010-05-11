package rooms
{
	//import game.Background;
	//import game.Particles;
	
	import game.Debug;
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
		[Embed(source = '../../level/Level2_thin.oel', mimeType = 'application/octet-stream')] private static const LEVEL:Class;
		
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
		private var TIMER_SON:Number = 30;	
		public var father:Player;
		public var son:Robot;
		public var sonIsAlive:Boolean = false;
		public var grandSon:Robot;
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
			
			// add SoundManager object to world
			//sound = new SoundManager();

			//add(new Particles);
			//add(new Background);

						
			//add player to world
			for each (var p:XML in level.objects[0].player)
			{
				father = new Player(p.@x, p.@y);
				add(father);
			}
			
			//set transmission time for father (one-shot alarm)
			father.timeToSon = new Alarm(TIMER_SON, onTimeToSon, 2);
			father.addTween(father.timeToSon, true);
			
			// for debug purposes, add one animated tile to list
			pathTileList[0] = new PathTile(5, 5, 30, 0);
			add(pathTileList[0]);
		}
		
		/**
		 * Transmit father to son
		 */
		public function onTimeToSon():void
		{
			trace("ring ring son is ready");
			son = new Robot(father.x, father.y);
			add(son);
		}
		
		/**
		 * Update the level.
		 */
		override public function update():void 
		{
			// update entities
			super.update();
			
			// update debug text
			updateDebugText();
			
			//TODO check if a new animated tile needs to be placed
			// use an as3.0 Vector class?
			addNewTile(father.x, father.y, 30); //TODO 30 is the step (move to property please!)

			
			//update SoundManager - required so the tweens actually get updated
			//sound.update();
			
			// if son is aliiven follow father
			if (sonIsAlive) 
			{
				// follow father for a certain amount of tiime then disappear
				// upon disappearence, transmit values to father, which then becomes son
			}
			
			// camera following
			cameraFollow();
			
		}
		
		override public function render():void 
		{
			super.render();
			debug.drawHitBox(father);
			debugHUD.render();
		}
		
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
				var index:int = pathTileList.push(new PathTile(col, row, 30, 0)); //TODO change 0 for pathType
				add(pathTileList[index-1]);
			}
		}
		
		/**
		 * update all the debug overlay info.
		 */
		public function updateDebugText():void
		{
			// draw debug information on screen
			var father_var:String = "Red - Vb: " + father.pathBaseSpeed[0] + " d: " + Number(father.pathDistance[0]).toFixed(2) + " V: " + Number(father.pathMaxVel[0]).toFixed(2) + "\n"
									+"Green - Vb: " + father.pathBaseSpeed[1] + " d: " + Number(father.pathDistance[1]).toFixed(2) +" V: " + Number(father.pathMaxVel[1]).toFixed(2) + "\n"
									+"Blue - Vb: " + father.pathBaseSpeed[2] + " d: " + Number(father.pathDistance[2]).toFixed(2) +" V: " + Number(father.pathMaxVel[2]).toFixed(2) + "\n"
									+"Timer Son: " + Math.floor(father.timeToSon.remaining) + "\n";
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
		private function get targetX():Number { return father.x - FP.width / 2; }
		private function get targetY():Number { return father.y - FP.height / 2; }
	}
}