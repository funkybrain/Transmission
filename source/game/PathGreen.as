package game
{
	import net.flashpunk.Entity;
	import net.flashpunk.graphics.Tilemap;
	import net.flashpunk.masks.Grid;
	import net.flashpunk.utils.Draw;
	import game.Debug;
	
	/**
	 * Path entity that contains the collision grid.
	 */
	public class PathGreen extends Path
	{
		/**
		 * Embed the tileset graphic.
		 */
		[Embed(source = '../../assets/spriteSheetPath.png')] private static const TILES:Class;
			
		
		/**
		 * Constructor. Load the floors from the level XML.
		 */
		public function PathGreen(level:XML, offset:int) 
		{
			
			_offset = offset;
			//trace("offset: " + _offset);
			
			super(level, TILES);
			
			// set entity type
			type = "green";
			
			// create and populate the tilemap from the level XML
			
			for each (var tile:XML in level.path_green[0].tile)
			{
				tiles.setTile(tile.@x / TILE_GRID, tile.@y / TILE_GRID, tiles.getIndex(tile.@tx / TILE_GRID, tile.@ty / TILE_GRID));
			}
			
			// create and populate the collision grid mask from the level XML
			
			for each (var solid:XML in level.mask_green[0].rect)
			{
				grid.setRect(solid.@x / SOLID_GRID, solid.@y / SOLID_GRID, solid.@w / SOLID_GRID, solid.@h / SOLID_GRID);
			}
		}
		
		override public function render():void 
		{
			super.render();
			
			if (_debug) 
			{
				for each (var solid:XML in _mylevel.mask_green[0].rect)
				{
					Draw.rect(solid.@x , solid.@y , solid.@w , solid.@h, 0x00FF00, 0.9);
				}
			}

		}
	}
}