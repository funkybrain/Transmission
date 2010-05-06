package rooms
{
	//import game.Background;
	//import game.Particles;
	
	import game.Debug;
	import game.PathRed;
	import game.PathBlue;
	import game.PathGreen;
	import game.Player;
	import game.SoundManager;
	import net.flashpunk.FP;
	
	public class Level extends LevelLoader
	{
		/**
		 * Level XML.
		 */
		[Embed(source = '../../level/Level1_thin.oel', mimeType = 'application/octet-stream')] private static const LEVEL:Class;
		
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
		public var father:Player;
		private var baseSpeed:Array = new Array(3);
		public var debug:Debug;
		public var sound:SoundManager;
		

		 
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
			// add SoundManager object to world
			//sound = new SoundManager();

			//add(new Particles);
			//add(new Background);
			
			// set base speed vb of father
			for (var i:int = 0; i < 3; i++) 
			{
				baseSpeed[i]=10
			}
			
			//add player to world
			for each (var p:XML in level.objects[0].player)
			{
				father = new Player(p.@x, p.@y, baseSpeed);
				add(father);
			}
		}
		
		/**
		 * Update the level.
		 */
		override public function update():void 
		{
			// update entities
			super.update();
			
			// update Soundmanager - required so the tweens actually get updated
			//sound.update();
			
			// camera following
			cameraFollow();
			
		}
		
		override public function render():void 
		{
			super.render();
			debug.drawHitBox(father);
			
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