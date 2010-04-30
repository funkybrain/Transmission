package
{
	import flash.display.Bitmap;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.geom.Point;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.geom.ColorTransform;
	import punk.core.*;
	import punk.util.*;
	import punk.*;
	
	/**
	 * Top-level FlashPunk class. Provides access to important game objects, such as World, Camera, etc. Also has useful functions for working with graphics, sound, and math.
	 */
	public class FP
	{
		/**
		 * The FlashPunk version.
		 */
		public static const VERSION:String = "0.86";
		
		/**
		 * The target FPS that FlashPunk will try to run at. Set the FPS in the Engine constructor, NOT by assigning this variable.
		 * @see punk.core.Engine#Engine()
		 */
		public static var fps:int;
		
		/**
		 * Access to the currently active World.
		 */
		public static var world:World;
		
		/**
		 * Change the active World by assigning this variable, do not assign FP.world yourself as the Engine needs to do some clean-up when switching.
		 */
		public static var goto:World;
		
		/**
		 * Access to the global Screen object.
		 */
		public static var screen:Screen;
		
		/**
		 * Access to the global Camera object.
		 */
		public static var camera:Camera;
		
		/**
		 * Controls the volume of both sound effects and music, a value from 0 to 1.
		 */
		public static var volume:Number = 1;
		
		/**
		 * Controls the volume of sound effects, a value from 0 to 1.
		 */
		public static var soundVolume:Number = 1;
		
		/**
		 * If sound effects and music should both be muted.
		 */
		public static var mute:Boolean = false;
		
		/**
		 * If sound effects should be muted.
		 */
		public static var soundMute:Boolean = false;
		
		/**
		 * Controls the volume of music, a value from 0 to 1.
		 */
		public static function get musicVolume():Number
		{
			return _musicVolume;
		}
		public static function set musicVolume(value:Number):void
		{
			var mute:Number = (_musicMute ? 0 : 1);
			_musicVolume = value < 0 ? 0 : value;
			_musicTR.volume = _musicVolume * mute;
			if (_musicCH) _musicCH.soundTransform = _musicTR;
		}
		
		/**
		 * If music should be muted.
		 */
		public static function get musicMute():Boolean
		{
			return _musicMute;
		}
		public static function set musicMute(value:Boolean):void
		{
			var mute:Number = (value ? 0 : 1);
			_musicMute = value;
			_musicTR.volume = _musicVolume * mute;
			if (_playing) _musicCH.soundTransform.volume = _musicVolume * mute;
		}
		
		/**
		 * Returns a stored Spritemap with the corresponding properties, or creates a new one and stores it if it doesn't exist.
		 * @param	bitmap		The embedded Bitmap class to create the Spritemap from.
		 * @param	imageW		The width of each image in the Spritemap. Set to 0 to use the width of the bitmap.
		 * @param	imageH		The height of each image in the Spritemap. Set to 0 to use the height of the bitmap.
		 * @param	flipX		Set to true to automatically prepare an X-flipped version of the bitmap.
		 * @param	flipY		Set to true to automatically prepare a Y-flipped version of the bitmap.
		 * @param	originX		The x-origin of the sprite, determines the offset position when drawing it.
		 * @param	originY		The y-origin of the sprite, determines the offset position when drawing it.
		 * @param	useCache	If the function should check for an existing Spritemap (true), or just create a new one (false).
		 * @return	A stored Spritemap corresponding to the provided properties, or a new one if one doesn't exist.
		 */
		public static function getSprite(bitmap:Class, imageW:int, imageH:int, flipX:Boolean = false, flipY:Boolean = false, originX:int = 0, originY:int = 0, useCache:Boolean = true):Spritemap
		{
			var data:Spritemap,
				temp:BitmapData,
				arr:Array = _sprite,
				pos:String = String(bitmap),
				fX:Boolean,
				fY:Boolean;
				
			if (useCache && arr[pos])
			{
				var spr:Spritemap = arr[pos];
				if ((!flipX || spr.flippedX) && (!flipY || spr.flippedY)) return arr[pos];
				fX = spr.flippedX;
				fY = spr.flippedY;
			}
			
			if (flipX || flipY || fX || fY)
			{
				temp = (new bitmap).bitmapData;
				if (!imageW) imageW = temp.width;
				if (!imageH) imageH = temp.height;
				var	w:int = flipX ? temp.width << 1 : temp.width,
					h:int = flipY ? temp.height << 1 : temp.height;
				data = new Spritemap(w, h, imageW, imageH, temp.width / imageW, originX, originY);
				data.copyPixels(temp, temp.rect, zero);
				matrix.b = matrix.c = 0;
				if (flipX || fX)
				{
					data.flippedX = true;
					data.imageR = w - imageW;
					matrix.a = -1;
					matrix.d = 1;
					matrix.tx = w;
					matrix.ty = 0;
					data.draw(temp, matrix);
				}
				if (flipY || fY)
				{
					data.flippedY = true;
					data.imageB = h >> 1;
					matrix.a = 1;
					matrix.d = -1;
					matrix.tx = 0;
					matrix.ty = h;
					data.draw(temp, matrix);
					if (flipX)
					{
						matrix.a = -1;
						matrix.tx = w;
						data.draw(temp, matrix);
					}
				}
				if (useCache) arr[pos] = data;
				return data;
			}
			
			temp = (new bitmap).bitmapData;
			if (!imageW) imageW = temp.width;
			if (!imageH) imageH = temp.height;
			data = new Spritemap(temp.width, temp.height, imageW, imageH, temp.width / imageW, originX, originY);
			data.copyPixels(temp, temp.rect, zero);
			data.imageW = imageW;
			data.imageH = imageH;
			
			if (useCache) arr[pos] = data;
			return data;
		}
		
		/**
		 * Returns a stored BitmapData. Useful if you have multiple classes that use the same embedded bitmap file.
		 * @param	bitmap	The embedded Bitmap class corresponding to the BitmapData.
		 */
		public static function getBitmapData(bitmap:Class):BitmapData
		{
			var arr:Array = _bitmap;
			if (arr[String(bitmap)]) return arr[String(bitmap)];
			return (arr[String(bitmap)] = (new bitmap()).bitmapData);
		}
		
		/**
		 * Plays a sound effect.
		 * @param	sound	The embedded Sound class to play.
		 * @param	vol		The volume factor, a value from 0 to 1.
		 * @param	pan		The panning factor, from -1 (left speaker) to 1 (right speaker).
		 */
		public static function play(sound:Class, vol:Number = 1, pan:Number = 0):void
		{
			if (mute || soundMute) return;
			var id:int = _soundID[String(sound)];
			if (!id)
			{
				_soundID[String(sound)] = id = _id;
				_sound[_id ++] = new sound();
			}
			_soundTR.volume = vol * soundVolume * volume;
			_soundTR.pan = pan;
			_sound[id].play(0, 0, _soundTR);
		}
		
		/**
		 * Plays the sound as a music track.
		 * @param	sound	The embedded Sound class to play.
		 * @param	loop	Whether the track should loop or not.
		 * @param	end		An optional function to call when the track finishes or loops.
		 */
		public static function musicPlay(sound:Class, loop:Boolean = true, end:Function = null):void
		{
			musicStop();
			_music = new sound();
			_musicTR.volume = _musicVolume * volume;
			_musicCH = _music.play(0, loop ? 999 : 0, _musicTR);
			_musicCH.addEventListener(Event.SOUND_COMPLETE, musicEnd, false, 0, true);
			_playing = true;
			_looping = loop;
			_paused = false;
			_position = 0;
			_end = end;
		}
		
		/**
		 * Stops the music track (will not trigger the end-sound function).
		 */
		public static function musicStop():void
		{
			if (!_playing) return;
			if (_musicCH.hasEventListener(Event.SOUND_COMPLETE))
				_musicCH.removeEventListener(Event.SOUND_COMPLETE, musicEnd, false);
			_musicCH.stop();
			_playing = _paused = false;
		}
		
		/**
		 * Pauses the music track (will not trigger the end-sound function).
		 */
		public static function musicPause():void
		{
			if (_playing && !_paused)
			{
				_position = _musicCH.position;
				if (_musicCH.hasEventListener(Event.SOUND_COMPLETE))
					_musicCH.removeEventListener(Event.SOUND_COMPLETE, musicEnd, false);
				_musicCH.stop();
				_playing = false;
				_paused = true;
			}
		}
		
		/**
		 * Resumes the music track from the position at which it was paused.
		 */
		public static function musicResume():void
		{
			if (_paused)
			{
				_musicCH = _music.play(_position, _looping ? 999 : 0, _musicTR);
				_musicCH.addEventListener(Event.SOUND_COMPLETE, musicEnd, false, 0, true);
				_playing = true;
				_paused = false;
			}
		}
		
		// function for the end-sound soundEvent to trigger
		private static function musicEnd(e:Event):void
		{
			if (_looping)
			{
				if (_musicCH.hasEventListener(Event.SOUND_COMPLETE))
					_musicCH.removeEventListener(Event.SOUND_COMPLETE, musicEnd, false);
				_musicCH = _music.play(0, 999, _musicTR);
				_musicCH.addEventListener(Event.SOUND_COMPLETE, musicEnd, false, 0, true);
			}
			else
			{
				_playing = false;
				_paused = false;
				_position = 0;
			}
			if (_end !== null) _end();
		}
		
		/**
		 * Randomly chooses and returns one of the provided values.
		 * @param	...objs	The Objects you want to randomly choose from. Can be ints, Numbers, Points, etc.
		 */
		public static function choose(...objs):*
		{
			return objs[int(objs.length * random)];
		}
		
		/**
		 * Finds the sign of the provided value.
		 * @param	value	The Number to evaluate.
		 * @return	1 if value > 0, -1 if value < 0, and 0 when value == 0.
		 */
		public static function sign(value:Number):int
		{
			return value < 0 ? -1 : (value > 0 ? 1 : 0);
		}
		
		/**
		 * Approaches the value towards the target, by the specified amount, without overshooting the target.
		 * @param	value	The starting value.
		 * @param	target	The target that you want value to approach.
		 * @param	amount	How much you want the value to approach target by.
		 */
		public static function approach(value:Number, target:Number, amount:Number):Number
		{
			return value < target ? (target < value + amount ? target : value + amount) : (target > value - amount ? target : value - amount);
		}
		
		/**
		 * Finds the angle (in degrees) from point 1 to point 2.
		 * @param	x1	The first x-position.
		 * @param	y1	The first y-position.
		 * @param	x2	The second x-position.
		 * @param	y2	The second y-position.
		 * @return	The angle from (x1, y1) to (x2, y2).
		 */
		public static function angle(x1:Number, y1:Number, x2:Number = 0, y2:Number = 0):Number
		{
			var a:Number = Math.atan2(y2 - y1, x2 - x1) * _DEG;
			return a < 0 ? a + 360 : a;
		}
		
		/**
		 * Retrieves a vector corresponding to the angle and distance provided.
		 * @param	angle	The angle of the vector (in degrees).
		 * @param	length	The distance to the vector from (0, 0).
		 * @return	A new Point object with x/y set to the length and angle from (0, 0).
		 */
		public static function anglePoint(angle:Number, length:Number = 1):Point
		{
			return new Point(Math.cos(angle * _RAD) * length, Math.sin(angle * _RAD) * length);
		}
		
		/**
		 * Returns the distance between two points.
		 * @param	x1	The first x-position.
		 * @param	y1	The first y-position.
		 * @param	x2	The second x-position.
		 * @param	y2	The second y-position.
		 */
		public static function distance(x1:Number, y1:Number, x2:Number = 0, y2:Number = 0):Number
		{
			return Math.sqrt((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1));
		}
		
		/**
		 * Returns the distance between two rectangles. Will return 0 if the rectangles overlap.
		 * @param	x1	The x-position of the first rect.
		 * @param	y1	The y-position of the first rect.
		 * @param	w1	The width of the first rect.
		 * @param	h1	The height of the first rect.
		 * @param	x2	The x-position of the second rect.
		 * @param	y2	The y-position of the second rect.
		 * @param	w2	The width of the second rect.
		 * @param	h2	The height of the second rect.
		 */
		public static function distanceRects(x1:Number, y1:Number, w1:Number, h1:Number, x2:Number, y2:Number, w2:Number, h2:Number):Number
		{
			if (x1 < x2 + w2 && x2 < x1 + w1)
			{
				if (y1 < y2 + h2 && y2 < y1 + h1) return 0;
				if (y1 > y2) return y1 - (y2 + h2);
				return y2 - (y1 + h1);
			}
			if (y1 < y2 + h2 && y2 < y1 + h1)
			{
				if (x1 > x2) return x1 - (x2 + w2);
				return x2 - (x1 + w1)
			}
			if (x1 > x2)
			{
				if (y1 > y2) return distance(x1, y1, (x2 + w2), (y2 + h2));
				return distance(x1, y1 + h1, x2 + w2, y2);
			}
			if (y1 > y2) return distance(x1 + w1, y1, x2, y2 + h2)
			return distance(x1 + w1, y1 + h1, x2, y2);
		}
		
		/**
		 * Returns the distance between a point and a rectangle. Returns 0 if the point is within the rectangle.
		 * @param	px	The x-position of the point.
		 * @param	py	The y-position of the point.
		 * @param	rx	The x-position of the rect.
		 * @param	ry	The y-position of the rect.
		 * @param	rw	The width of the rect.
		 * @param	rh	The height of the rect.
		 */
		public static function distanceRectPoint(px:Number, py:Number, rx:Number, ry:Number, rw:Number, rh:Number):Number
		{
			if (px >= rx && px <= rx + rw)
			{
				if (py >= ry && py <= ry + rh) return 0;
				if (py > ry) return py - (ry + rh);
				return ry - py;
			}
			if (py >= ry && py <= ry + rh)
			{
				if (px > rx) return px - (rx + rw);
				return rx - px;
			}
			if (px > rx)
			{
				if (py > ry) return distance(px, py, rx + rw, ry + rh);
				return distance(px, py, rx + rw, ry);
			}
			if (py > ry) return distance(px, py, rx, ry + rh)
			return distance(px, py, rx, ry);
		}
		
		/**
		 * Clamps the value within the minimum and maximum values.
		 * @param	value	The Number to evaluate.
		 * @param	min		The minimum range.
		 * @param	max		The maximum range.
		 * @see #scaleClamp()
		 */
		public static function clamp(value:Number, min:Number, max:Number):Number
		{
			if (max > min)
			{
				value = value < max ? value : max;
				return value > min ? value : min;
			}
			value = value < min ? value : min;
			return value > max ? value : max;
		}
		
		/**
		 * Transfers a value from one scale to another scale. For example, scale(.5, 0, 1, 10, 20) == 15, and scale(3, 0, 5, 100, 0) == 40.
		 * @param	value	The value on the first scale.
		 * @param	min		The minimum range of the first scale.
		 * @param	max		The maximum range of the first scale.
		 * @param	min2	The minimum range of the second scale.
		 * @param	max2	The maximum range of the second scale.
		 * @see #scaleClamp()
		 */
		public static function scale(value:Number, min:Number, max:Number, min2:Number, max2:Number):Number
		{
			return min2 + ((value - min) / (max - min)) * (max2 - min2);
		}
		
		/**
		 * Transfers a value from one scale to another scale, but clamps the return value within the second scale.
		 * @param	value	The value on the first scale.
		 * @param	min		The minimum range of the first scale.
		 * @param	max		The maximum range of the first scale.
		 * @param	min2	The minimum range of the second scale.
		 * @param	max2	The maximum range of the second scale.
		 * @see #scale()
		 * @see #clamp()
		 */
		public static function scaleClamp(value:Number, min:Number, max:Number, min2:Number, max2:Number):Number
		{
			value = min2 + ((value - min) / (max - min)) * (max2 - min2);
			if (max2 > min2)
			{
				value = value < max2 ? value : max2;
				return value > min2 ? value : min2;
			}
			value = value < min2 ? value : min2;
			return value > max2 ? value : max2;
		}
		
		/**
		 * Returns a color value by combining the chosen RGB values.
		 * @param	R	The red value of the color, from 0 to 255.
		 * @param	G	The green value of the color, from 0 to 255.
		 * @param	B	The blue value of the color, from 0 to 255.
		 */
		public static function getColorRGB(R:uint = 0, G:uint = 0, B:uint = 0):uint
		{
			return R << 16 | G << 8 | B;
		}
		
		/**
		 * Returns a value from 0 to 255, representing the red value of the color.
		 * @param	color	The color to evaluate.
		 */
		public static function getRed(color:uint):uint
		{
			return color >> 16 & 0xFF;
		}
		
		/**
		 * Returns a value from 0 to 255, representing the green value of the color.
		 * @param	color	The color to evaluate.
		 */
		public static function getGreen(color:uint):uint
		{
			return color >> 8 & 0xFF;
		}
		
		/**
		 * Returns a value from 0 to 255, representing the blue value of the color.
		 * @param	color	The color to evaluate.
		 */
		public static function getBlue(color:uint):uint
		{
			return color & 0xFF;
		}
		
		/**
		 * The random seed used by FP's random functions.
		 */
		public static function get randomSeed():uint
		{
			return _getSeed;
		}
		public static function set randomSeed(value:uint):void
		{
			_seed = clamp(value, 1, 2147483646);
			_getSeed = _seed;
		}
		
		/**
		 * Randomizes the random seed using Flash's Math.random() function.
		 */
		public static function randomizeSeed():void
		{
			randomSeed = 2147483647 * Math.random();
		}
		
		/**
		 * A pseudo-random Number produced using FP's random seed, where 0 <= Number < 1.
		 */
		public static function get random():Number
		{
			_seed = (_seed * 16807) % 2147483647;
			return _seed / 2147483647;
		}
		
		/**
		 * Returns a pseudo-random uint.
		 * @param	amount	The returned uint will always be 0 <= uint < amount.
		 */
		public static function rand(amount:uint):uint
		{
			_seed = (_seed * 16807) % 2147483647;
			return (_seed / 2147483647) * amount;
		}
		
		// global Flash DisplayObjects, you normally won't need to access these
		/** @private */ public static var stage:Stage;
		/** @private */ public static var engine:Engine;
		
		// global objects used commonly in rendering, collisions, etc.
		/** @private */ public static var point:Point = new Point;
		/** @private */ public static var point2:Point = new Point;
		/** @private */ public static var zero:Point = new Point;
		/** @private */ public static var matrix:Matrix = new Matrix;
		/** @private */ public static var rect:Rectangle = new Rectangle;
		/** @private */ public static var color:ColorTransform = new ColorTransform;
		/** @private */ public static var sprite:Sprite = new Sprite;
		/** @private */ public static var entity:Entity; // <-- created in Engine
		
		// used for rad-to-deg and deg-to-rad conversion
		private static const _DEG:Number = -180 / Math.PI;
		private static const _RAD:Number = Math.PI / -180;
		
		// storage arrays
		private static var _sprite:Array = [];		// Spritemaps
		private static var _rotation:Array = [];	// Rotationmaps
		private static var _bitmap:Array = [];		// BitmapDatas
		
		// variables for playing sounds/music
		private static var _id:int = 0;
		private static var _soundID:Array = [];
		private static var _sound:Vector.<Sound> = new Vector.<Sound>();
		private static var _soundTR:SoundTransform = new SoundTransform();
		private static var _music:Sound;
		private static var _musicTR:SoundTransform = new SoundTransform();
		private static var _musicCH:SoundChannel;
		private static var _playing:Boolean = false;
		private static var _looping:Boolean = false;
		private static var _paused:Boolean = false;
		private static var _position:Number = 0;
		private static var _musicVolume:Number = 1;
		private static var _musicMute:Boolean = false;
		private static var _end:Function = null;
		
		// pseudo-random number generation (the seed is set in Engine's contructor)
		private static var _seed:uint = 0;
		private static var _getSeed:uint;
	}
}