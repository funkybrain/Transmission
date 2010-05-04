package rooms
{
	//import game.Background;
	//import game.Particles;
	
	import game.Debug;
	import game.PathRed;
	import game.PathBlue;
	import game.PathGreen;
	import game.Player;
	import net.flashpunk.FP;
	
	public class Level extends LevelLoader
	{
		/**
		 * Level XML.
		 */
		[Embed(source = '../../level/Level1.oel', mimeType = 'application/octet-stream')] private static const LEVEL:Class;
		
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
		public var player:Player;
		public var debug:Debug;
		

		 
		/**
		 * Constructor.
		 */
		public function Level()
		{
			super(LEVEL);
			width = level.width;
			height = level.height;
			
			add(new PathRed(level));
			add(new PathBlue(level));
			add(new PathGreen(level));
			player = new Player();
			add(player);
			
			debug = new Debug();

			//add(new Particles);
			//add(new Background);
			
/*			for each (var p:XML in level.objects[0].player)
			{
				player = new Player(p.@x, p.@y);
				add(player);
			}*/
		}
		
		/**
		 * Update the level.
		 */
		override public function update():void 
		{
			// update entities
			super.update();
			
			// camera following
			cameraFollow();
			
		}
		
		override public function render():void 
		{
			super.render();
			debug.drawHitBox(player);
			
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