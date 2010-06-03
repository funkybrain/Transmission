package game 
{
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import net.flashpunk.Entity;
	import net.flashpunk.graphics.Tilemap;
	import net.flashpunk.masks.Grid;
	import net.flashpunk.utils.Draw;
	import game.Debug;

	public class Path extends Entity
	{

		/**
		 * Floors information.
		 */
		public var tiles:Tilemap;
		
		public var grid:Grid;
		
		protected var _mylevel:XML;
		
		public static const TILE_GRID:uint=30;
		
		public const SOLID_GRID:uint=10;
		
		protected var _offset:int;
		
		protected var _debug:Boolean = false; // to print grid mask on screen
		
		protected var tile_x:int;
		protected var grid_x:int;

		
		public function Path(level:XML, tileMap:Class) 
		{
			// set entity type
			_mylevel = level;
			//_tiles = TILES as BitmapData;
			
			layer = 20;
			
			// create and populate the tilemap from the level XML
			graphic = tiles = new Tilemap(tileMap, level.width, level.height, TILE_GRID, TILE_GRID);
			
			
			// create and populate the collision grid mask from the level XML
			mask = grid = new Grid(level.width, level.height, SOLID_GRID, SOLID_GRID);
			
			this.x = _offset;
			
		}
		
		override public function added():void 
		{
			super.added();
			trace("added path to world at: " + this.x);
		}
		
	}

}