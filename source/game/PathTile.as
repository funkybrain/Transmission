package game 
{
	import net.flashpunk.Entity;
	import net.flashpunk.graphics.Spritemap;
	import net.flashpunk.graphics.Image;
	import net.flashpunk.tweens.misc.VarTween;
	import net.flashpunk.utils.Ease;
	
	/**
	 * This class is used as
	 * an animated path tile factory!
	 */
	
	public class PathTile extends Entity
	{
		/**
		 * Tile graphic.
		 */
		[Embed(source = '../../assets/spriteRed.png')] private const RED_TILE:Class;
		public var redtile:Spritemap = new Spritemap(RED_TILE, 30, 30);
		
		[Embed(source = '../../assets/spriteGreen.png')] private const GREEN_TILE:Class;
		public var greentile:Spritemap = new Spritemap(GREEN_TILE, 30, 30);

		[Embed(source = '../../assets/spriteBlue.png')] private const BLUE_TILE:Class;
		public var bluetile:Spritemap = new Spritemap(BLUE_TILE, 30, 30);
		
		/**
		 * Animation properties.
		 */
		private var frames:Array;
		private var fadeIn:VarTween;
		
		/**
		 * Row and Col properties used to position animated tile in world.
		 */
		public var col:int;
		public var row:int;
		 
		/**
		 * Constructor.
		 * @param	_col	the column index within the world/level
		 * @param	_row	the row index within the world/level
		 * @param	_step	this is the grid step used to convert x,y coordinates in row/col
		 * @param	_tile	index of path type (red=0, green=1, blue=2)
		 */
		public function PathTile(_col:int, _row:int, _step:int, _tile:uint) 
		{
			// place the entity at the correct position in the world
			this.x = _col * _step;
			this.y = _row * _step;
			this.col = _col;
			this.row = _row;
			layer = 1;
			// set the path tile's graphic property to a Spritemap object
			// and create an animation
			playTileAnimation(_tile);

		}
		
		private function playTileAnimation(_tile:uint):void
		{
			var t:uint = _tile, spriteName:Spritemap;
			//trace("tile: " + t);
			
			switch (t)
			{
			case 0:
				spriteName = redtile;
				break;
			case 1:
				spriteName = greentile;
				break;
			case 2:
				spriteName = bluetile;
				break;
			default:
				break; // no tile?
				
			}
			
			graphic = spriteName;
			spriteName.alpha = 0.1;
			frames = new Array( 0, 1, 2, 3, 4 );
			spriteName.add("appear", frames, 4, false); // won't loop
			spriteName.play("appear");
			
			//fade sprite in
			fadeIn = new VarTween();
			addTween(fadeIn);
			fadeIn.tween(spriteName, "alpha", 1, 4, Ease.backIn);
			fadeIn.start();
		}
		
	}

}