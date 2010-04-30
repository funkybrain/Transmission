package punk.core
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundMixer;
	import flash.media.SoundTransform;
	import flash.utils.getQualifiedClassName;
	import flash.system.System;
	
	/**
	 * A playing-field that game Entities can be added to. Used for organization, eg. "Menu", "Level1", etc.
	 * @see FP#world
	 * @see FP#goto
	 * @see punk.core.Entity
	 */
	public class World extends Core
	{
		/**
		 * <strong>WARNING:</strong> Do not add or remove entities to a World in its constructor. Instead, override the init() function and do it there.
		 */
		public function World() 
		{
			FP.camera.x = FP.camera.y = 0;
		}
		
		/**
		 * Override this. Called when the World is initiated, has been assigned to FP.world, and will now be updated in the game loop.
		 */
		public function init():void
		{
			
		}
		
		/**
		 * Override this. Here you can specify what happens when the Flash Player gains focus.
		 * @see Engine#runUnfocused
		 */
		public function focusIn():void
		{
			
		}
		
		/**
		 * Override this. Here you can specify what happens when the Flash Player loses focus.
		 * @see Engine#runUnfocused
		 */
		public function focusOut():void
		{
			
		}
		
		/**
		 * Adds an Entity to the World.
		 * @param	e	The Entity to add.
		 * @return	The Entity that was added.
		 */
		public function add(e:Entity):Entity
		{
			if (e._added) return e;
			
			// add to update and render lists
			if (_updateFirst) _updateFirst._updatePrev = _renderFirst._renderPrev = e;
			e._updateNext = _updateFirst;
			e._renderNext = _renderFirst;
			e._updatePrev = e._renderPrev = null;
			_updateFirst = _renderFirst = e;
			_entityNum ++;
			
			// set information
			e._added = true;
			
			// set depth
			var d:int = e._depth;
			e._depth = int.MIN_VALUE;
			e.depth = ~d + 1;
			
			// set collision type
			if (e._collisionType) e.type = e._collisionType;
			
			return e;
		}
		
		/**
		 * Removes an Entity from the World.
		 * @param	e	The Entity to remove.
		 * @return 	The Entity that was removed.
		 */
		public function remove(e:Entity):Entity
		{
			if (!e._added) return e;
			
			// remove from update and render lists
			if (e == _updateFirst) _updateFirst = e._updateNext;
			if (e == _renderFirst) _renderFirst = e._renderNext;
			if (e._updateNext) e._updateNext._updatePrev = e._updatePrev;
			if (e._renderNext) e._renderNext._renderPrev = e._renderPrev;
			if (e._updatePrev) e._updatePrev._updateNext = e._updateNext;
			if (e._renderPrev) e._renderPrev._renderNext = e._renderNext;
			
			// remove collidable type
			if (e._collisionType)
			{
				if (_collisionFirst[e._collisionType] == e) _collisionFirst[e._collisionType] = e._collisionNext;
				if (e._collisionNext) e._collisionNext._collisionPrev = e._collisionPrev;
				if (e._collisionPrev) e._collisionPrev._collisionNext = e._collisionNext;
				e._collisionNext = e._collisionPrev = null;
			}
			
			// set information
			_entityNum --;
			e._added = false;
			return e;
		}
		
		/**
		 * Adds a Vector of Entities to the World.
		 * @param	v	The Vector of Entities to add.
		 */
		public function addVector(v:Vector.<Entity>):void
		{
			var i:int = v.length;
			while (i --) add(v[i]);
		}
		
		/**
		 * Removes a Vector of Entities from the World.
		 * @param	v	The Vector of Entities to remove.
		 */
		public function removeVector(v:Vector.<Entity>):void
		{
			var i:int = v.length;
			while (i --) remove(v[i]);
		}
		
		/**
		 * Removes all Entities from the World.
		 */
		public function removeAll():void
		{
			var e:Entity = _updateFirst;
			while (e)
			{
				// remove the enitity
				e._collisionPrev = e._collisionNext = null;
				e._added = false;
				e = e._updateNext;
			}
			_renderFirst = _updateFirst = null;
			_collisionFirst = [];
			_entityNum = 0;
			System.gc();
			System.gc();
		}
		
		/**
		 * Removes the Entity from the World, storing it so it can be retrieved later.
		 * @param	e	The Entity you want to recycle.
		 * @return	The recycled Entity.
		 */
		public function recycle(e:Entity):Entity
		{
			if (!e._added) return e;
			e._recycleNext = _recycle[e._class];
			_recycle[e._class] = e;
			_recycleNum ++;
			return remove(e);
		}
		
		/**
		 * Returns the next available recycled Entity of the Class type, creating it if one doesn't exist.
		 * @param	c			The Class type you want to search for.
		 * @param	addToWorld	Optionally, you can add the Entity to FP.world in the same call. The default is true.
		 * @return	The next available or created Entity.
		 */
		public function create(c:Class, addToWorld:Boolean = true):Entity
		{
			var s:String = getQualifiedClassName(c),
				e:Entity = _recycle[s];
			if (e)
			{
				if (addToWorld)
				{
					_recycle[s] = e._recycleNext;
					e._recycleNext = null;
					_recycleNum --;
					return add(e);
				}
				return e;
			}
			return add(new c);
		}
		
		/**
		 * Returns the next available recycled Entity of the Class type, returning null if it doesn't exist.
		 * @param	c			The Class type you want to search for.
		 * @param	addToWorld	Optionally, you can add the Entity to FP.world in the same call. The default is true.
		 * @return	The next available recycled Entity.
		 */
		public function next(c:Class, addToWorld:Boolean = true):Entity
		{
			var s:String = getQualifiedClassName(c),
				e:Entity = _recycle[s];
			if (e && addToWorld)
			{
				_recycle[s] = e._recycleNext;
				e._recycleNext = null;
				_recycleNum --;
				return add(e);
			}
			return e;
		}
		
		/**
		 * How many Entities are in this World.
		 */
		public function get count():int
		{
			return _entityNum;
		}
		
		/**
		 * Returns the amount of Entities of a specific Class type in this World.
		 * @param	c	The Class type to count.
		 */
		public function countClass(c:Class):int
		{
			var e:Entity = _updateFirst,
				n:int = 0;
			while (e)
			{
				if (e is c) n ++;
				e = e._updateNext;
			}
			return n;
		}
		
		/**
		 * Counts the amount of recycled Entities of the Class type.
		 * @param	c	The Class type you want to count.
		 */
		public function countRecycledClass(c:Class):int
		{
			var s:String = getQualifiedClassName(c),
				e:Entity = _recycle[s],
				n:int = 0;
			while (e)
			{
				n ++;
				e = e._recycleNext;
			}
			return n;
		}
		
		/**
		 * The amount of recycled Entities that are currently stored.
		 */
		public function get countRecycled():int
		{
			return _recycleNum;
		}
		
		/**
		 * Returns the amount of Entities of a specific Class type in this World.
		 * @param	type	The collision-type to count.
		 */
		public function countType(type:String):int
		{
			var e:Entity = _collisionFirst[type],
				n:int = 0;
			while (e)
			{
				n ++;
				e = e._collisionNext;
			}
			return n;
		}
		
		/**
		 * Returns whether the World contains any Entities of the specific Class type.
		 * @param	c	The Class type to search for.
		 */
		public function hasClass(c:Class):Boolean
		{
			var e:Entity = _updateFirst;
			while (e)
			{
				if (e is c) return true;
				e = e._updateNext;
			}
			return false;
		}
		
		/**
		 * Returns whether the World contains any Entities of the specific collision-type.
		 * @param	type	The collision-type to search for.
		 * @return
		 */
		public function hasType(type:String):Boolean
		{
			if (_collisionFirst[type]) return true;
			return false;
		}
		
		/**
		 * Returns a Vector of all Entities of a specific Class type in this World.
		 * @param	c	The Class type to add to the Vector.
		 */
		public function getClass(c:Class):Vector.<Entity>
		{
			var e:Entity = _updateFirst,
				v:Vector.<Entity> = new Vector.<Entity>(),
				n:int = 0;
			while (e)
			{
				if (e is c) v[n ++] = e;
				e = e._updateNext;
			}
			return v;
		}
		
		/**
		 * Returns a Vector of all Entities of a specific collision-type in this World.
		 * @param	type	The collision-type to add to the Vector.
		 */
		public function getType(type:String):Vector.<Entity>
		{
			var e:Entity = _collisionFirst[type],
				v:Vector.<Entity> = new Vector.<Entity>(),
				n:int = 0;
			while (e)
			{
				v[n ++] = e;
				e = e._collisionNext;
			}
			return v;
		}
		
		/**
		 * Returns the first Entity of the Class type in World, or null if there are none.
		 * @param	c	The Class type to search for.
		 */
		public function getClassFirst(c:Class):Entity
		{
			var e:Entity = _updateFirst;
			while (e)
			{
				if (e is c) return e;
				e = e._updateNext;
			}
			return null;
		}
		
		/**
		 * Returns the first Entity of the collision-type in World, or null if there are none.
		 * @param	type	The collision-type to search for.
		 */
		public function getTypeFirst(type:String):Entity
		{
			return _collisionFirst[type];
		}
		
		/**
		 * Returns the Entity of the Class type in World nearest to the position, or null if there are none.
		 * @param	c			The Class type you want to search for.
		 * @param	x			The x-position to check distance from.
		 * @param	y			The y-position to check distance from.
		 * @param	useHitbox	Set this to true if you want to check the distance from each Entity's hitbox, rather than just their x/y position.
		 */
		public function getClassNearest(c:Class, x:Number, y:Number, useHitbox:Boolean = false):Entity
		{
			var e:Entity = _updateFirst,
				nearDist:Number = Number.MAX_VALUE,
				near:Entity = null,
				dist:Number;
			
			// distance from hitbox
			if (useHitbox)
			{
				while (e)
				{
					if (e is c)
					{
						dist = FP.distanceRectPoint(x, y, e.x - e.originX, e.y - e.originY, e.width, e.height);
						if (dist < nearDist)
						{
							near = e;
							nearDist = dist;
						}
					}
					e = e._updateNext;
				}
				return near;
			}
			
			// distance from position
			while (e)
			{
				if (e is c)
				{
					dist = Math.sqrt((e.x - x) * (e.x - x) + (e.y - y) * (e.y - y));
					if (dist < nearDist)
					{
						near = e;
						nearDist = dist;
					}
				}
				e = e._updateNext;
			}
			return near;
		}
		
		/**
		 * Returns the Entity of the collision-type in World nearest to the position, or null if there are none.
		 * @param	type		The collision-type you want to search for.
		 * @param	x			The x-position to check distance from.
		 * @param	y			The y-position to check distance from.
		 * @param	useHitbox	Set this to true if you want to check the distance from each Entity's hitbox, rather than just their x/y position.
		 */
		public function getTypeNearest(type:String, x:Number, y:Number, useHitbox:Boolean = false):Entity
		{
			var e:Entity = _collisionFirst[type],
				nearDist:Number = Number.MAX_VALUE,
				near:Entity = null,
				dist:Number;
			
			// distance from hitbox
			if (useHitbox)
			{
				while (e)
				{
					dist = FP.distanceRectPoint(x, y, e.x - e.originX, e.y - e.originY, e.width, e.height);
					if (dist < nearDist)
					{
						near = e;
						nearDist = dist;
					}
					e = e._updateNext;
				}
				return near;
			}
			
			// distance from position
			while (e)
			{
				dist = Math.sqrt((e.x - x) * (e.x - x) + (e.y - y) * (e.y - y));
				if (dist < nearDist)
				{
					near = e;
					nearDist = dist;
				}
				e = e._updateNext;
			}
			return near;
		}
		
		/**
		 * Performs a function for each Entity of the specific Class type in this World.
		 * @param	c			The Class type to search for.
		 * @param	perform		The function to perform, which has a single parameter e:Entity to which each Entity is passed.
		 */
		public function withClass(c:Class, perform:Function):void
		{
			var e:Entity = _updateFirst;
			while (e)
			{
				if (e is c) perform(e as c);
				e = e._updateNext;
			}
		}
		
		/**
		 * Performs a function for each Entity of the specific collision-type in this World.
		 * @param	type		The collision-type to search for.
		 * @param	perform		The function to perform, which has a single parameter, e, to which each Entity is passed.
		 */
		public function withType(type:String, perform:Function):void
		{
			var e:Entity = _collisionFirst[type];
			while (e)
			{
				perform(e);
				e = e._collisionNext;
			}
		}
		
		/**
		 * Returns which entity collides with the specified point in the World.
		 * @param	type	Only Entities of this collision-type will be checked.
		 * @param	x		The x-position.
		 * @param	y		The y-position.
		 * @return	The first Entity of type that was collided with, or null when there is no collision.
		 */
		public function collidePoint(type:String, x:Number, y:Number):Entity
		{
			var e:Entity = _collisionFirst[type];
			while (e)
			{
				if (x >= e.x - e.originX
				&& y >= e.y - e.originY
				&& x < e.x - e.originX + e.width
				&& y < e.y - e.originY + e.height)
				{
					if (!e.collideBack)
					{
						if (!e.mask || e.mask.getPixel(x - e.x + e.originX, y - e.y + e.originY)) return e;
					}
					else
					{
						FP.entity.width = FP.entity.height = 1;
						if (e.checkBack(FP.entity, x, y)) return e;
					}
				}
				e = e._collisionNext;
			}
			return null;
		}
		
		/**
		 * Returns which entity collides with the specified rectangle in the World.
		 * @param	type	Only Entities of this collision-type will be checked.
		 * @param	x		The x-position of the rectangle.
		 * @param	y		The y-position of the rectangle.
		 * @param	width	The width of the rectangle.
		 * @param	height	The height of the rectangle.
		 * @return	The first Entity of type that was collided with, or null when there is no collision.
		 */
		public function collideRect(type:String, x:Number, y:Number, width:Number, height:Number):Entity
		{
			FP.entity.width = width;
			FP.entity.height = height;
			return FP.entity.collide(type, x, y);
		}
		
		/**
		 * The x-position of the mouse in the World (not the position on the Screen)
		 * @see punk.util.Input#mouseX
		 * @see punk.core.Camera#mouseX
		 * @see punk.core.Screen#mouseX
		 */
		public function get mouseX():int
		{
			return FP.stage.mouseX / FP.screen.scale + FP.camera.x;
		}
		
		/**
		 * The y-position of the mouse in the World (not the position on the Screen)
		 * @see punk.util.Input#mouseY
		 * @see punk.core.Camera#mouseY
		 * @see punk.core.Screen#mouseY
		 */
		public function get mouseY():int
		{
			return FP.stage.mouseY / FP.screen.scale + FP.camera.y;
		}
		
		/**
		 * @private updates the world and calls its update() function (so entities are updated before the world)
		 */
		internal final function updateF():void
		{
			if (!active) return;
			var e:Entity = _updateFirst;
			while (e)
			{
				if (e.active) e.update();
				if (e._alarmFirst) e._alarmFirst.update();
				e = e._updateNext;
			}
			if (_alarmFirst) _alarmFirst.update();
			update();
		}
		
		/**
		 * @private renders the world and calls its render() function (so entities are updated before the world)
		 */ 
		internal final function renderF():void
		{
			if (!visible) return;
			var e:Entity = _renderFirst;
			while (e)
			{
				if (e.visible) e.render();
				e = e._renderNext;
			}
			render();
		}
		
		// linked lists
		/** @private */ internal var _entityNum:int;
		/** @private */ internal var _updateFirst:Entity;
		/** @private */ internal var _renderFirst:Entity;
		/** @private */ internal var _collisionFirst:Array = [];
		
		private var _recycle:Array = [];
		private var _recycleNum:int = 0;
		
		// global objects
		private var _point:Point = FP.point;
		private var _zero:Point = FP.zero;
		private var _rect:Rectangle = FP.rect;
		private var _matrix:Matrix = FP.matrix;
	}
}