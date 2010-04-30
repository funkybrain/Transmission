package punk.core 
{
	import flash.display.Graphics;
	import flash.display.LineScaleMode;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	/**
	 * The base class for active game objects that should update, render, or use alarms.
	 * @see punk.core.World
	 * @see punk.core.Entity
	 */
	public class Core 
	{
		/**
		 * When this is false, update() will not be called for this object.
		 * @see #update()
		 */
		public var active:Boolean = true;
		
		/**
		 * When this is false, render() will not be called for this object.
		 * @see #render()
		 */
		public var visible:Boolean = true;
		
		/**
		 * A reference to the last Alarm that was triggered for this object.
		 * 
		 * <p><strong>NOTE:</strong> Be aware that if multiple Alarms triggered in the same frame, this will only reference the last.</p>
		 */
		public var alarmLast:Alarm;
		
		/**
		 * Constructor.
		 */
		public function Core() 
		{
			
		}
		
		/**
		 * Override this. Called every frame, override for game logic, controls, movement, etc.
		 * @see #active
		 */
		public function update():void
		{
			if (_alarmFirst) _alarmFirst.update();
		}
		
		/**
		 * Override this. Called every frame, override for animation, rendering, etc.
		 * @see #visible
		 */
		public function render():void
		{
			
		}
		
		/**
		 * Adds an alarm to this object.
		 * @param	alarm
		 * @return	The Alarm that was added.
		 * @see #removeAlarm()
		 */
		public function addAlarm(alarm:Alarm, start:Boolean = true):Alarm
		{
			if (alarm._added) return alarm;
			if (_alarmFirst) _alarmFirst._prev = alarm;
			alarm._next = _alarmFirst;
			alarm._added = true;
			alarm._entity = this;
			_alarmFirst = alarm;
			if (start) alarm.start();
			return alarm;
		}
		
		/**
		 * Removes the alarm from this object. No reference is retained to the removed Alarm.
		 * @param	alarm	The Alarm object to remove.
		 * @return	The Alarm that was removed.
		 * @see #removeAllAlarms()
		 * @see #addAlarm()
		 */
		public function removeAlarm(alarm:Alarm):Alarm
		{
			if (!alarm._added) return alarm;
			if (alarm._prev) alarm._prev._next = alarm._next;
			if (alarm._next) alarm._next._prev = alarm._prev;
			if (_alarmFirst == alarm) _alarmFirst = alarm._next;
			alarm._next = alarm._prev = null;
			alarm._entity = null;
			alarm._added = false;
			return alarm;
		}
		
		/**
		 * Removes all Alarms from this object. References are not retained to the removed Alarms.
		 */
		public function removeAllAlarms():void
		{
			var a:Alarm;
			while (_alarmFirst)
			{
				_alarmFirst._prev = null;
				a = _alarmFirst;
				_alarmFirst = a._next;
				a._next = null;
				a._added = false;
			}
		}
		
		/**
		 * Draws an unscaled, unrotated Spritemap to FP.screen.
		 * @param	sprite	The Spritemap you want to draw.
		 * @param	image	The image of the Spritemap you want to draw.
		 * @param	x		The x-position in the World you want to draw it.
		 * @param	y		The y-position in the World you want to draw it.
		 * @param	flipX	If you want to draw the x-flipped version.
		 * @param	flipY	If you want to draw the y-flipped version.
		 */
		public function drawSprite(sprite:Spritemap, image:int = 0, x:int = 0, y:int = 0, flipX:Boolean = false, flipY:Boolean = false):void
		{
			// get the image & drawing position
			_rect.x = flipX ? sprite.imageR - image * sprite.imageW : image * sprite.imageW;
			_rect.y = flipY ? sprite.imageB : 0;
			_rect.width = sprite.imageW;
			_rect.height = sprite.imageH;
			_point.x = x - FP.camera.x - sprite.originX;
			_point.y = y - FP.camera.y - sprite.originY;
			
			// draw onto the screen
			FP.screen.copyPixels(sprite, _rect, _point);
		}
		
		/**
		 * Draws a filled rectangle to FP.screen.
		 * @param	x		The x-position in the World to draw it.
		 * @param	y		The y-position in the World to draw it.
		 * @param	w		The width of the rectangle.
		 * @param	h		The height of the rectangle.
		 * @param	color	The fill-color of the rectangle.
		 * @param	alpha	The alpha value of the color.
		 */
		public function drawRect(x:int, y:int, w:int, h:int, color:uint = 0x000000, alpha:Number = 1):void
		{
			if (alpha >= 1)
			{
				_rect.x = x - FP.camera.x;
				_rect.y = y - FP.camera.y;
				_rect.width = w;
				_rect.height = h;
				FP.screen.fillRect(_rect, color);
				return;
			}
			_graphics.clear();
			_graphics.beginFill(color, alpha);
			_graphics.drawRect(x - FP.camera.x, y - FP.camera.y, w, h);
			_graphics.endFill();
			FP.screen.draw(_sprite);
		}
		
		/**
		 * Draws a filled circle to FP.screen.
		 * @param	x		The x-position of the center of the circle.
		 * @param	y		The y-position of the center of the circle.
		 * @param	radius	The radius of the circle.
		 * @param	color	The fill-color of the circle.
		 * @param	alpha	The alpha value of the color.
		 */
		public function drawCircle(x:int, y:int, radius:Number, color:uint = 0x000000, alpha:Number = 1):void
		{
			_graphics.clear();
			_graphics.beginFill(color, alpha);
			_graphics.drawCircle(x - FP.camera.x, y - FP.camera.y, radius);
			_graphics.endFill();
			FP.screen.draw(_sprite);
		}
		
		/**
		 * Draws a pixelated, non-antialiased line to the Screen.
		 * @param	x1		The starting x-position in the World.
		 * @param	y1		The starting y-position in the World.
		 * @param	x2		The ending x-position in the World.
		 * @param	y2		The ending y-position in the World.
		 * @param	color	The color to draw.
		 */
		public function drawLine(x1:int, y1:int, x2:int, y2:int, color:uint = 0x000000):void
		{
			// get the drawing positions
			x1 -= FP.camera.x;
			y1 -= FP.camera.y;
			x2 -= FP.camera.x;
			y2 -= FP.camera.y;
			
			// get the drawing difference
			var screen:Screen = FP.screen,
				X:Number = Math.abs(x2 - x1),
				Y:Number = Math.abs(y2 - y1),
				xx:int,
				yy:int;
			
			// draw a single pixel
			if (X == 0)
			{
				if (Y == 0)
				{
					screen.setPixel(x1, y1, color);
					return;
				}
				// draw a straight vertical line
				yy = y2 > y1 ? 1 : -1;
				while (y1 != y2)
				{
					screen.setPixel(x1, y1, color);
					y1 += yy;
				}
				screen.setPixel(x2, y2, color);
				return;
			}
			
			if (Y == 0)
			{
				// draw a straight horizontal line
				xx = x2 > x1 ? 1 : -1;
				while (x1 != x2)
				{
					screen.setPixel(x1, y1, color);
					x1 += xx;
				}
				screen.setPixel(x2, y2, color);
				return;
			}
			
			xx = x2 > x1 ? 1 : -1;
			yy = y2 > y1 ? 1 : -1;
			var c:Number = 0,
				slope:Number;
			
			if (X > Y)
			{
				slope = Y / X;
				c = .5;
				while (x1 != x2)
				{
					screen.setPixel(x1, y1, color);
					x1 += xx;
					c += slope;
					if (c >= 1)
					{
						y1 += yy;
						c -= 1;
					}
				}
				screen.setPixel(x2, y2, color);
				return;
			}
			else
			{
				slope = X / Y;
				c = .5;
				while (y1 != y2)
				{
					screen.setPixel(x1, y1, color);
					y1 += yy;
					c += slope;
					if (c >= 1)
					{
						x1 += xx;
						c -= 1;
					}
				}
				screen.setPixel(x2, y2, color);
				return;
			}
		}
		
		/**
		 * Draws a smooth, antialiased line to the Screen with an optional alpha value.
		 * @param	x1		The starting x-position of the line.
		 * @param	y1		The starting y-position of the line.
		 * @param	x2		The ending x-position of the line.
		 * @param	y2		The ending y-position of the line.
		 * @param	color	The color of the line.
		 * @param	alpha	The alpha value of the color.
		 * @param	thick	The thickness of the line.
		 */
		public function drawLinePlus(x1:int, y1:int, x2:int, y2:int, color:uint = 0xFF000000, alpha:Number = 1, thick:Number = 1):void
		{
			_graphics.clear();
			_graphics.lineStyle(thick, color, alpha, false, LineScaleMode.NONE);
			_graphics.moveTo(x1 - FP.camera.x, y1 - FP.camera.y);
			_graphics.lineTo(x2 - FP.camera.x, y2 - FP.camera.y);
			FP.screen.draw(_sprite);
		}
		
		// the first alarm in the alarm list
		/** @private */ internal var _alarmFirst:Alarm;
		
		// global objects
		private var _point:Point = FP.point;
		private var _rect:Rectangle = FP.rect;
		private var _sprite:Sprite = FP.sprite;
		private var _graphics:Graphics = FP.sprite.graphics;
	}
}