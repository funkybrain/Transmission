package game
{
	import net.flashpunk.Entity;
	import net.flashpunk.graphics.Tilemap;
	import net.flashpunk.masks.Grid;
	import net.flashpunk.utils.Draw;
	
	/**
	 * Path entity that contains the collision grid.
	 */
	public class PathRed extends Entity
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
		private var mylevel:XML;
		private var debug:Draw;
		
		/**
		 * Constructor. Load the floors from the level XML.
		 */
		public function PathRed(level:XML) 
		{
			// set entity type
			type = "red";
			mylevel = level;
			debug = new Draw();
			// create and populate the tilemap from the level XML
			graphic = tiles = new Tilemap(TILES, level.width, level.height, 30, 30);
			for each (var tile:XML in level.path_red[0].tile)
			{
				tiles.setTile(tile.@x / 30, tile.@y / 30, tiles.getIndex(tile.@tx / 30, tile.@ty / 30));
			}
			
			// create and populate the collision grid mask from the level XML
			mask = grid = new Grid(level.width, level.height, 30, 30);
			for each (var solid:XML in level.mask_red[0].rect)
			{
				grid.setRect(solid.@x / 30, solid.@y / 30, solid.@w / 30, solid.@h / 30);
				
			}
		}
		
		override public function render():void 
		{
			super.render();
			
			if (Debug.flag==true) 
			{
				for each (var solid:XML in mylevel.mask_red[0].rect)
				{
					Draw.rect(solid.@x , solid.@y , solid.@w , solid.@h, 0xFF0000, 0.9);
				}
			}

		}
	}
}