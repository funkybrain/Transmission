﻿package game
{
	import flash.display.BitmapData;
	import net.flashpunk.Entity;
	import net.flashpunk.graphics.Tilemap;
	import net.flashpunk.masks.Grid;
	import net.flashpunk.utils.Draw;
	import game.Debug;
	
	/**
	 * Path entity that contains the collision grid.
	 */
	public class PathBlue extends Path
	{

		/**
		 * Embed the tileset graphic.
		 */
		[Embed(source = '../../assets/spriteSheetPath.png')] private static var TILES:Class;
		
		
		/**
		 * Constructor. Load the floors from the level XML.
		 */
		public function PathBlue(level:XML, offset:int) 
		{
			_offset = offset;
						
			super(level, TILES);
		
			// set entity type
			type = "blue";
			
			
			// create and populate the tilemap from the level XML
			for each (var tile:XML in level.path_blue[0].tile)
			{
				tiles.setTile(tile.@x / TILE_GRID, tile.@y / TILE_GRID, tiles.getIndex(tile.@tx / TILE_GRID, tile.@ty / TILE_GRID));
			}
			
			// create and populate the collision grid mask from the level XML
			
			for each (var solid:XML in level.mask_blue[0].rect)
			{
				grid.setRect(solid.@x / SOLID_GRID, solid.@y / SOLID_GRID, solid.@w / SOLID_GRID, solid.@h / SOLID_GRID);
	
			}
		}
		
		override public function render():void 
		{
			super.render();
			
			if (_debug) 
			{
				for each (var solid:XML in _mylevel.mask_blue[0].rect)
				{
					Draw.rect(grid_x , solid.@y , solid.@w , solid.@h, 0x0000FF, 0.9);
	
				}
			}

		}
	}
}