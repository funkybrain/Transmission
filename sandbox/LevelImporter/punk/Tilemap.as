package punk 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import punk.core.Entity;
	
	/**
	 * A special Entity designed for drawing large grids of tiles to FP.screen. Tilemaps will also be treated specially
	 * when collided against, using their grid information to make collisions faster than using lots of rectangle Entities.
	 */
	public class Tilemap extends Entity
	{
		/**
		 * The collision threshold. All tiles with a value less than this will be checked in collision searches.
		 */
		public var threshold:uint = uint.MAX_VALUE;
		
		/**
		 * You must specify the size and properties of a Tilemap in its constructor, as these cannot be changed afterwards.
		 * 
		 * <p><strong>NOTE:</strong> If you want to just use an invisible Tilemap for collision, set the tileset parameter to null when you call the constructor.</p>
		 * @param	tileset		The bitmap tileset to use. Tile 1 is the first tile, and you count up from left-to-right and top-to-bottom.
		 * @param	width		The width (in pixels) of the Tilemap.
		 * @param	height		The height (in pixels) of the Tilemap.
		 * @param	tileWidth	The tile-width, which must be a divisor of width. If not, width is reduced.
		 * @param	tileHeight	The tile-height, which must be a divisor of height. If not, height is reduced.
		 */
		public function Tilemap(tileset:Class, width:int, height:int, tileWidth:int, tileHeight:int) 
		{
			_tileW = tileWidth;
			_tileH = tileHeight;
			_width = width = width - (width % _tileW);
			_height = height = height - (height % _tileH);
			_columns = width / _tileW;
			_rows = height / _tileH;
			
			// check for oversized grid
			if (_columns > MAX_WIDTH || _rows > MAX_HEIGHT) throw new Error("Attempting to create an oversized Tilemap. Maximum size is " + String(MAX_WIDTH) + " x " + String(MAX_HEIGHT) + " tiles.");
			
			// tilemap collision grid
			_grid = new BitmapData(_columns, _rows, false, 0);
			
			// create the display bitmap reference
			_dataW = MAX_WIDTH - (MAX_WIDTH % _tileW);
			_dataH = MAX_HEIGHT - (MAX_HEIGHT % _tileH);
			if (_dataW > width) _dataW = width;
			if (_dataH > height) _dataH = height;
			_dataRows = _dataW / _tileW;
			_dataCols = _dataH / _tileH;
			_dataR = new Rectangle(0, 0, _dataW, _dataH);
			_refW = Math.ceil(width / _dataW);
			_refH = Math.ceil(height / _dataH);
			_ref = new BitmapData(_refW, _refH, false, 0);
			
			// create the display bitmaps
			_data = new Vector.<BitmapData>();
			var x:int = 0,
				y:int = 0,
				i:int = 0,
				w:int,
				h:int;
			while (y < _refH)
			{
				while (x < _refH)
				{
					w = (x == (_refW - 1)) ? _dataW - (width % _dataW) : _dataW;
					h = (y == (_refH - 1)) ? _dataH - (height % _dataH) : _dataH;
					_data[i] = new BitmapData(w, h, true, 0);
					_ref.setPixel(x, y, i);
					i ++;
					x ++;
				}
				x = 0;
				y ++;
			}
			
			// create the tileset and its rectangles
			visible = false;
			if (tileset)
			{
				visible = true;
				_tileset = FP.getBitmapData(tileset);
				_tilerect = new Vector.<Rectangle>();
				w = _tileset.width;
				h = _tileset.height;
				x = y = i = 0;
				while (y < h)
				{
					while (x < w)
					{
						_tilerect[i ++] = new Rectangle(x, y, _tileW, _tileH);
						x += _tileW;
					}
					x = 0;
					y += _tileH;
				}
			}
			
			// set the collision properties
			this.width = _width;
			this.height = _height;
			collideBack = true;
			depth = int.MAX_VALUE;
		}
		
		/**
		 * Sets the tile at the specified column and row.
		 * @param	x		The tile column.
		 * @param	y		The tile row.
		 * @param	tile	The tile value.
		 */
		public function setTile(x:int, y:int, tile:uint = 0):void
		{
			_grid.setPixel(x, y, tile);
			if (!_tileset) return;
			if (tile)
			{
				_point.x = (x * _tileW) % _dataW;
				_point.y = (y * _tileH) % _dataH;
				_data[_ref.getPixel(x / _dataRows, y / _dataCols)].copyPixels(_tileset, _tilerect[tile - 1], _point);
				return;
			}
			_rect.x = (x * _tileW) % _dataW;
			_rect.y = (y * _tileH) % _dataH;
			_rect.width = _tileW;
			_rect.height = _tileH;
			_data[_ref.getPixel(x / _dataW, y / _dataH)].fillRect(_rect, 0);
		}
		
		/**
		 * Sets a region of tiles.
		 * @param	x		The first column of the region of tiles.
		 * @param	y		The first row of the region of tiles.
		 * @param	width	How many columns of tiles to fill.
		 * @param	height	How many rows of tiles to fill.
		 * @param	tile	The tile value to fill in the region.
		 */
		public function setRegion(x:int, y:int, width:int = 1, height:int = 1, tile:int = 0):void
		{
			var xx:int = 0,
				yy:int = 0;
			while (yy < height)
			{
				while (xx < width)
				{
					setTile(x + xx, y + yy, tile);
					xx ++;
				}
				xx = 0;
				yy ++;
			}
		}
		
		/**
		 * Gets the tile at the specified column and row.
		 * @param	x		The tile column.
		 * @param	y		The tile row.
		 */
		public function getTile(x:int, y:int):uint
		{
			return _grid.getPixel(x, y);
		}
		
		/**
		 * Clears all the Tilemap information, leaving a blank, transparent Tilemap.
		 */
		public function clear():void
		{
			for each (var b:BitmapData in _data) b.fillRect(_dataR, 0);
			_grid.fillRect(_grid.rect, 0);
		}
		
		/**
		 * Loads the Tilemap data from a string.
		 * @param	str			The string data, which is a set of tile values separated by the columnSep and rowSep strings.
		 * @param	columnSep	The string that separates each tile value on a row, default is ",".
		 * @param	rowSep		The string that separates each row of tiles, default is "\n".
		 */
		public function loadFromString(str:String, columnSep:String = ",", rowSep:String = "\n"):void
		{
			var row:Array = str.split(rowSep),
				rows:int = row.length,
				col:Array,
				cols:int,
				tile:uint,
				x:int = 0,
				y:int = 0;
			while (y < rows)
			{
				col = row[y].split(columnSep);
				cols = col.length;
				while (x < cols)
				{
					setTile(x, y, uint(col[x ++]));
				}
				x = 0;
				y ++;
			}
		}
		
		/**
		 * Loads the Tilemap data from an array.
		 * @param	a		The array data, which is a one-dimensional array of tile values.
		 * @param	columns	How many columns the function should break the array into. Leave as 0 to use Tilemap columns.
		 * @param	rows	How many rows the function should break the array into. Leave as 0 to use Tilemap rows.
		 */
		public function loadFromArray(a:Array, columns:int = 0, rows:int = 0):void
		{
			if (!columns) columns = _columns;
			if (!rows) rows = _rows;
			var i:int = 0,
				x:int = 0,
				y:int = 0;
			while (y < rows)
			{
				while (x < columns)
				{
					setTile(x, y, uint(a[i ++]));
					x ++;
				}
				x = 0;
				y ++;
			}
		}
		
		/**
		 * Loads the Tilemap data from a BitmapData object.
		 * @param	data	The BitmapData to load tiles from.
		 */
		public function loadFromBitmap(bitmap:Class):void
		{
			var data:BitmapData = (new bitmap).bitmapData,
				w:int = Math.min(data.width, _columns),
				h:int = Math.min(data.height, _rows),
				x:int = 0,
				y:int = 0,
				xx:int = 0,
				yy:int = 0;
			while (y < h)
			{
				while (x < w)
				{
					loadPixel(xx, yy, x, y, data.getPixel(x, y));
					xx += _tileW;
					x ++;
				}
				yy += _tileH;
				x = xx = 0;
				y ++;
			}
		}
		
		/**
		 * Called by loadFromBitmap() for each pixel on the bitmap, override this to specify your own loading behavior.
		 * @param	x		The x-position where the tile will be placed.
		 * @param	y		The y-position where the tile will be placed.
		 * @param	column	The column of the tile (x-position of the pixel on the bitmap).
		 * @param	row		The row of the tile (y-position of the pixel on the bitmap).
		 * @param	color	The color of the pixel on the bitmap.
		 */
		protected function loadPixel(x:int, y:int, column:int, row:int, color:uint):void
		{
			setTile(column, row, color);
		}
		
		/**
		 * @private Tilemaps have special collision conditions, which are checked in this function
		 */
		override public function checkBack(entity:Entity, x:int, y:int):Boolean 
		{
			x -= entity.originX + this.x;
			y -= entity.originY + this.y;
			_point.x = x;
			_point.y = y;
			var x2:int = (x + entity.width - 1) / _tileW,
				y2:int = (y + entity.height - 1) / _tileH,
				x1:int = x = x / _tileW,
				y1:int = y / _tileH,
				p:uint = 0;
			
			// entity has no mask
			if (!entity.mask)
			{
				while (y1 <= y2)
				{
					while (x1 <= x2)
					{
						p = _grid.getPixel(x1, y1);
						if (p && p <= threshold) return true;
						x1 ++;
					}
					y1 ++;
					x1 = x;
				}
				return false;
			}
			
			// entity has collision mask
			_rect.width = _tileW;
			_rect.height = _tileH;
			while (y1 <= y2)
			{
				while (x1 <= x2)
				{
					p = _grid.getPixel(x1, y1);
					if (p && p <= threshold)
					{
						_rect.x = x1 * _tileW;
						_rect.y = y1 * _tileH;
						if (entity.mask.hitTest(_point, threshold, _rect)) return true;
					}
					x1 ++;
				}
				y1 ++;
				x1 = x;
			}
			return false;
		}
		
		/**
		 * Tilemaps render all their tiles to FP.screen. If you override this, the
		 * sprite will not be drawn unless you call super.render() in the override.
		 */
		override public function render():void 
		{
			if (!_tileset) return;
			_point.x = x - FP.camera.x;
			_point.y = y - FP.camera.y;
			var xx:int = 0,
				yy:int = 0,
				i:int = 0;
			while (yy < _refH)
			{
				while (xx < _refW)
				{
					FP.screen.copyPixels(_data[i ++], _dataR, _point);
					_point.x += _dataW;
					xx ++;
				}
				_point.x = x - FP.camera.x;
				_point.y += _dataH;
				xx = 0;
				yy ++;
			}
		}
		
		/**
		 * Tilemaps do not currently support collide(). Have Entities collide <strong>against</strong> Tilemaps instead.
		 */
		override public function collide(type:String, x:int, y:int):Entity 
		{
			throw new Error("Tilemap does not currently support collide().");
			return null
		}
		
		/**
		 * Tilemaps do not currently support collideWith(). Have Entities collide <strong>against</strong> Tilemaps instead.
		 */
		override public function collideWith(entity:Entity, x:int, y:int):Boolean
		{
			throw new Error("Tilemap does not currently support collideWith().");
			return false;
		}
		
		/**
		 * Tilemaps do not currently support collideEach(). Have Entities collide <strong>against</strong> Tilemaps instead.
		 */
		override public function collideEach(type:String, x:int, y:int, perform:Function):void 
		{
			throw new Error("Tilemap does not currently support collideEach().");
		}
		
		// maximum size of the grid
		private const MAX_WIDTH:int = 4000;
		private const MAX_HEIGHT:int = 4000;
		
		// Tilemap info
		private var _width:int;
		private var _height:int;
		private var _tileW:int;
		private var _tileH:int;
		private var _columns:int;
		private var _rows:int;
		private var _grid:BitmapData;
		private var _ref:BitmapData;
		private var _refW:int;
		private var _refH:int;
		private var _data:Vector.<BitmapData>;
		private var _dataW:int;
		private var _dataH:int;
		private var _dataRows:int;
		private var _dataCols:int;
		private var _dataR:Rectangle;
		private var _tileset:BitmapData;
		private var _tilerect:Vector.<Rectangle>;
		
		// global objects
		private var _point:Point = FP.point;
		private var _rect:Rectangle = FP.rect;
	}
}