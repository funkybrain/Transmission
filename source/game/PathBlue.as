package game
{
	import net.flashpunk.Entity;
	import net.flashpunk.graphics.Tilemap;
	import net.flashpunk.masks.Grid;
	
	/**
	 * Path entity that contains the collision grid.
	 */
	public class PathBlue extends Entity
	{
		/**
		 * Embed the tileset graphic.
		 */
		[Embed(source = '../../assets/spritesheetBVR.png')] private static const TILES:Class;
		
		/**
		 * Floors information.
		 */
		public var tiles:Tilemap;
		public var grid:Grid;
		
		/**
		 * Constructor. Load the floors from the level XML.
		 */
		public function PathBlue(level:XML) 
		{
			// set entity type
			type = "blue";
			
			// create and populate the tilemap from the level XML
			graphic = tiles = new Tilemap(TILES, level.width, level.height, 30, 30);
			for each (var tile:XML in level.path_blue[0].tile)
			{
				tiles.setTile(tile.@x / 30, tile.@y / 30, tiles.getIndex(tile.@tx / 30, tile.@ty / 30));
			}
			
			// create and populate the collision grid mask from the level XML
			mask = grid = new Grid(level.width, level.height, 30, 30);
			for each (var solid:XML in level.mask_blue[0].rect)
			{
				grid.setRect(solid.@x / 30, solid.@y / 30, solid.@w / 30, solid.@h / 30);
			}
		}
	}
}