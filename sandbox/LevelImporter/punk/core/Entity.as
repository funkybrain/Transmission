package punk.core
{
	import flash.display.BitmapData;
	import flash.geom.*;
	import flash.utils.getQualifiedClassName;
	import punk.util.*;
	import punk.*;
	
	/**
	 * Basic game object which can be added to Worlds. They have an x/y position and functions for collision.
	 * @see punk.core.World
	 */
	public class Entity extends Core
	{	
		/**
		 * The Entity's x-position in the World.
		 */
		public var x:Number = 0;
		
		/**
		 * The Entity's y-position in the World.
		 */
		public var y:Number = 0;
		
		/**
		 * If this Entity should respond to collision checks.
		 */
		public var collidable:Boolean = true;
		
		/**
		 * If this Entity is already in a World.
		 */
		public function get added():Boolean
		{
			return _added;
		}
		
		/**
		 * The width of this Entity's hitbox.
		 */
		public var width:int = 0;
		
		/**
		 * The height of this Entity's hitbox.
		 */
		public var height:int = 0;
		
		/**
		 * The x-origin of this Entity's hitbox.
		 */
		public var originX:int = 0;
		
		/**
		 * The y-origin of this Entity's hitbox.
		 */
		public var originY:int = 0;
		
		/**
		 * An optional collision mask for the Entity. When colliding, hitboxes are evaluated first.
		 * Then, if the Entity has a mask, pixel-perfect intersection will then be checked. In a
		 * mask, all pixels with alpha > 0 will be checked against for collision.
		 */
		public var mask:BitmapData = null;
		
		/**
		 * Constructor.
		 */
		public function Entity() 
		{
			_class = getQualifiedClassName(this);
		}
		
		/**
		 * Enables the Entity, setting visible, active, and collidable all to true.
		 */
		public function enable():void
		{
			active = visible = collidable = true;
		}
		
		/**
		 * Disables the Entity, setting visible, active, and collidable all to false.
		 */
		public function disable():void
		{
			active = visible = collidable = false;
		}
		
		/**
		 * Checks for a collision when this Entity is placed at a specific position.
		 * @param	type	Only Entities of this collision-type will be checked.
		 * @param	x		The x-position at which to emulate the collision.
		 * @param	y		The y-position at which to emulate the collision.
		 * @return	The first Entity of type that was collided with, or null when there is no collision.
		 */
		public function collide(type:String, x:int, y:int):Entity
		{
			var entity:Entity = FP.world._collisionFirst[type];
			
			// this entity has no mask
			if (!mask)
			{
				while (entity)
				{
					if (entity.collidable && entity !== this
					&& x - originX + width > entity.x - entity.originX
					&& y - originY + height > entity.y - entity.originY
					&& x - originX < entity.x - entity.originX + entity.width
					&& y - originY < entity.y - entity.originY + entity.height)
					{
						if (!entity.mask)
						{
							if (!entity.collideBack || entity.checkBack(this, x, y))
								return entity;
						}
						else
						{
							_point.x = entity.x - entity.originX;
							_point.y = entity.y - entity.originY;
							_rect.x = x - originX;
							_rect.y = y - originY;
							_rect.width = width;
							_rect.height = height;
							if (entity.mask.hitTest(_point, 1, _rect) && (!entity.collideBack || entity.checkBack(this, x, y)))
								return entity;
						}
					}
					entity = entity._collisionNext;
				}
				return null;
			}
			
			// this entity has a mask
			_point.x = x - originX;
			_point.y = y - originY;
			while (entity)
			{
				if (entity.collidable && entity !== this
				&& x - originX + width > entity.x - entity.originX
				&& y - originY + height > entity.y - entity.originY
				&& x - originX < entity.x - entity.originX + entity.width
				&& y - originY < entity.y - entity.originY + entity.height)
				{
					if (!entity.mask)
					{
						_rect.x = entity.x - entity.originX;
						_rect.y = entity.y - entity.originY;
						_rect.width = entity.width;
						_rect.height = entity.height;
						if (mask.hitTest(_point, 1, _rect) && (!entity.collideBack || entity.checkBack(this, x, y)))
							return entity;
					}
					else
					{
						_point2.x = entity.x - entity.originX;
						_point2.y = entity.y - entity.originY;
						if (mask.hitTest(_point, 1, entity.mask, _point2, 1) && (!entity.collideBack || entity.checkBack(this, x, y)))
							return entity;
					}
				}
				entity = entity._collisionNext;
			}
			return null;
		}
		
		/**
		 * Returns if this Entity collides against another specific Entity when at the position.
		 * @param	entity	The Entity to test for collision against.
		 * @param	x		The x-position at which to emulate the collision.
		 * @param	y		The y-position at which to emulate the collision.
		 */
		public function collideWith(entity:Entity, x:int, y:int):Boolean
		{
			if (entity == this) return false;
			
			// this entity has no mask
			if (!mask)
			{
				if (entity.collidable
				&& x - originX + width > entity.x - entity.originX
				&& y - originY + height > entity.y - entity.originY
				&& x - originX < entity.x - entity.originX + entity.width
				&& y - originY < entity.y - entity.originY + entity.height)
				{
					if (!entity.mask)  return !entity.collideBack || entity.checkBack(this, x, y);
					_point.x = entity.x - entity.originX;
					_point.y = entity.y - entity.originY;
					_rect.x = x - originX;
					_rect.y = y - originY;
					_rect.width = width;
					_rect.height = height;
					return entity.mask.hitTest(_point, 1, _rect) && (!entity.collideBack || entity.checkBack(this, x, y));
				}
				return false;
			}
			
			// this entity has a mask
			if (entity.collidable
			&& x - originX + width > entity.x - entity.originX
			&& y - originY + height > entity.y - entity.originY
			&& x - originX < entity.x - entity.originX + entity.width
			&& y - originY < entity.y - entity.originY + entity.height)
			{
				_point.x = x - originX;
				_point.y = y - originY;
				if (!entity.mask)
				{
					_rect.x = entity.x - entity.originX;
					_rect.y = entity.y - entity.originY;
					_rect.width = entity.width;
					_rect.height = entity.height;
					return mask.hitTest(_point, 1, _rect) && (!entity.collideBack || entity.checkBack(this, x, y));
				}
				_point2.x = entity.x - entity.originX;
				_point2.y = entity.y - entity.originY;
				return mask.hitTest(_point, 1, entity.mask, _point2, 1) && (!entity.collideBack || entity.checkBack(this, x, y));
			}
			return false;
		}
		
		/**
		 * Performs a function for each Entity that this one collides against when at the position.
		 * @param	type		Only Entities of this collision-type will be checked.
		 * @param	x			The x-position at which to emulate the collision.
		 * @param	y			The y-position at which to emulate the collision.
		 * @param	perform		Function to perform for each interection. The function must have a single e:Entity parameter to which each intersecting Entity will be passed.
		 */
		public function collideEach(type:String, x:int, y:int, perform:Function):void
		{
			var entity:Entity = FP.world._collisionFirst[type];
			
			// this entity has no mask
			if (!mask)
			{
				while (entity)
				{
					if (entity.collidable && entity !== this
					&& x - originX + width > entity.x - entity.originX
					&& y - originY + height > entity.y - entity.originY
					&& x - originX < entity.x - entity.originX + entity.width
					&& y - originY < entity.y - entity.originY + entity.height)
					{
						if (!entity.mask)
						{
							if (!entity.collideBack || entity.checkBack(this, x, y))
								perform(entity);
						}
						else
						{
							_point.x = entity.x - entity.originX;
							_point.y = entity.y - entity.originY;
							_rect.x = x - originX;
							_rect.y = y - originY;
							_rect.width = width;
							_rect.height = height;
							if (entity.mask.hitTest(_point, 1, _rect) && (!entity.collideBack || entity.checkBack(this, x, y)))
								perform(entity);
						}
					}
					entity = entity._collisionNext;
				}
				return;
			}
			
			// this entity has a mask
			while (entity)
			{
				if (entity.collidable && entity !== this
				&& x - originX + width > entity.x - entity.originX
				&& y - originY + height > entity.y - entity.originY
				&& x - originX < entity.x - entity.originX + entity.width
				&& y - originY < entity.y - entity.originY + entity.height)
				{
					_point.x = x - originX;
					_point.y = y - originY;
					if (!entity.mask)
					{
						_rect.x = entity.x - entity.originX;
						_rect.y = entity.y - entity.originY;
						_rect.width = entity.width;
						_rect.height = entity.height;
						if (mask.hitTest(_point, 1, _rect) && (!entity.collideBack || entity.checkBack(this, x, y)))
							perform(entity);
					}
					else
					{
						_point2.x = entity.x - entity.originX;
						_point2.y = entity.y - entity.originY;
						if (mask.hitTest(_point, 1, entity.mask, _point2, 1) && (!entity.collideBack || entity.checkBack(this, x, y)))
							perform(entity);
					}
				}
				entity = entity._collisionNext;
			}
		}
		
		/**
		 * Checks if this Entity collides with the specified rectangle.
		 * @param	rx		The x-position of the rectangle.
		 * @param	ry		The y-position of the rectangle.
		 * @param	rwidth	The width of the rectangle.
		 * @param	rheight	The height of the rectangle.
		 */
		public function collideRect(rx:int, ry:int, rwidth:int, rheight:int):Boolean
		{
			if (x - originX + width > rx
			&& y - originY + height > ry
			&& x - originX < rx + rwidth
			&& y - originY < ry + rheight)
			{
				if (collideBack)
				{
					FP.entity.width = rwidth;
					FP.entity.height = rheight;
					return checkBack(FP.entity, rx, ry);
				}
				if (!mask) return true;
				_point.x = x - originX;
				_point.y = y - originY;
				_rect.x = rx;
				_rect.y = ry;
				_rect.width = rwidth;
				_rect.height = rheight;
				return mask.hitTest(_point, 1, _rect);
			}
			return false;
		}
		
		/**
		 * Checks if this Entity collides with the specified point.
		 * @param	x	The x-position of the point.
		 * @param	y	The y-position of the point.
		 */
		public function collidePoint(x:int, y:int):Boolean
		{
			if (x >= this.x - originX
			&& y >= this.y - originY
			&& x < this.x - originX + width
			&& y < this.y - originY + height)
			{
				if (!collideBack) return !mask || mask.getPixel(x - this.x + originX, y - this.y + originY);
				FP.entity.width = FP.entity.height = 1;
				return checkBack(FP.entity, x, y);
			}
			return false;
		}
		
		/**
		 * Sets the Entity's hitbox properties.
		 * @param	width		The width of the hitbox.
		 * @param	height		The height of the hitbox.
		 * @param	xorigin		The x-origin of the hitbox.
		 * @param	yorigin		The y-origin of the hitbox.
		 */
		public function setHitbox(width:int, height:int, xorigin:int = 0, yorigin:int = 0):void
		{
			this.width = width;
			this.height = height;
			originX = xorigin;
			originY = yorigin;
			this.mask = null;
		}
			
		/**
		 * Sets the Entity's mask properties. The Entity's width and height
		 * will be set to the size of the mask when you call this function.
		 * @param	mask		The BitmapData to use as a mask.
		 * @param	xorigin		The x-origin of the hitbox.
		 * @param	yorigin		The y-origin of the hitbox.
		 */
		public function setMask(mask:BitmapData, xorigin:int = 0, yorigin:int = 0):void
		{
			originX = xorigin;
			originY = yorigin;
			width = mask.width;
			height = mask.height;
			this.mask = mask;
		}
		
		/**
		 * The collision search-type, so this Entity will be checked when other Entities collide against this type.
		 */
		public function get type():String
		{
			return _collisionType;
		}
		public function set type(value:String):void
		{
			if (!_added)
			{
				_collisionType = value;
				return;
			}
			
			// remove it from its current type
			if (_collisionType && FP.world._collisionFirst[_collisionType])
			{
				if (FP.world._collisionFirst[_collisionType] == this) FP.world._collisionFirst[_collisionType] = _collisionNext;
				if (_collisionNext) _collisionNext._collisionPrev = _collisionPrev;
				if (_collisionPrev) _collisionPrev._collisionNext = _collisionNext;
				_collisionNext = _collisionPrev = null;
			}
			
			_collisionType = value;
			if (!_collisionType) return;
			
			// insert it in as a new type
			if (FP.world._collisionFirst[value])
			{
				_collisionNext = FP.world._collisionFirst[value];
				_collisionNext._collisionPrev = this;
			}
			else _collisionNext = null;
			_collisionPrev = null;
			FP.world._collisionFirst[value] = this;
		}
		
		/**
		 * The Entity's drawing depth (those with higher depth are rendered first).
		 */
		public function get depth():int
		{
			return ~_depth + 1;
		}
		public function set depth(value:int):void
		{
			value = ~value + 1;
			if (_added && value != _depth)
			{
				var entity:Entity;
				if (value > _depth)
				{
					if (_renderNext && _renderNext._depth < value)
					{
						entity = _renderNext;
						while (entity._renderNext && entity._renderNext._depth < value) entity = entity._renderNext;
						// switch this one out
						if (_renderPrev) _renderPrev._renderNext = _renderNext;
						else FP.world._renderFirst = _renderNext;
						_renderNext._renderPrev = _renderPrev;
						// insert this one in after entity
						_renderNext = entity._renderNext;
						_renderPrev = entity;
						entity._renderNext = this;
						if (_renderNext) _renderNext._renderPrev = this;
					}
				}
				else
				{
					if (_renderPrev && _renderPrev._depth > value)
					{
						entity = _renderPrev;
						while (entity._renderPrev && entity._renderPrev._depth > value) entity = entity._renderPrev;
						// switch this one out
						_renderPrev._renderNext = _renderNext;
						if (_renderNext) _renderNext._renderPrev = _renderPrev;
						// insert this one in before entity
						_renderPrev = entity._renderPrev;
						_renderNext = entity;
						entity._renderPrev = this;
						if (_renderPrev) _renderPrev._renderNext = this;
						else FP.world._renderFirst = this;
					}
				}
			}
			_depth = value;
		}
		
		/**
		 * Gets the Entity of the Class type that is nearest to this one when this one is at the specified location.
		 * @param	c			The Class type to search for.
		 * @param	x			The x-position of this Entity.
		 * @param	y			The y-position fo this Entity.
		 * @param	useHitBox	Optionally choose to calculate the distance between hitboxes, as opposed to just comparing x/y positions.
		 */
		public function getNearestClass(c:Class, x:Number, y:Number, useHitBox:Boolean = false):Entity
		{
			var e:Entity = FP.world._updateFirst,
				nearDist:Number = Number.MAX_VALUE,
				near:Entity = null,
				dist:Number;
			if (useHitBox)
			{
				x -= originX;
				y -= originY;
				while (e)
				{
					if (e is c)
					{
						dist = FP.distanceRects(x, y, width, height, e.x - e.originX, e.y - e.originY, e.width, e.height);
						if (dist < nearDist)
						{
							nearDist = dist;
							near = e;
						}
					}
					e = e._updateNext;
				}
				return near;
			}
			while (e)
			{
				if (e is c)
				{
					dist = FP.distance(x, y, e.x, e.y);
					if (dist < nearDist)
					{
						nearDist = dist;
						near = e;
					}
				}
				e = e._updateNext;
			}
			return near;
		}
		
		/**
		 * Gets the Entity of the collision-type that is nearest to this one when this one is at the specified location.
		 * @param	type		The collision-type to search for.
		 * @param	x			The x-position of this Entity.
		 * @param	y			The y-position fo this Entity.
		 * @param	useHitBox	Optionally choose to calculate the distance between hitboxes, as opposed to just comparing x/y positions.
		 */
		public function getNearestType(type:String, x:Number, y:Number, useHitBox:Boolean = false):Entity
		{
			var e:Entity = FP.world._updateFirst,
				nearDist:Number = Number.MAX_VALUE,
				near:Entity = null,
				dist:Number;
			if (useHitBox)
			{
				x -= originX;
				y -= originY;
				while (e)
				{
					if (e._collisionType == type)
					{
						dist = FP.distanceRects(x, y, width, height, e.x - e.originX, e.y - e.originY, e.width, e.height);
						if (dist < nearDist)
						{
							nearDist = dist;
							near = e;
						}
					}
					e = e._updateNext;
				}
				return near;
			}
			while (e)
			{
				if (e._collisionType == type)
				{
					dist = FP.distance(x, y, e.x, e.y);
					if (dist < nearDist)
					{
						nearDist = dist;
						near = e;
					}
				}
				e = e._updateNext;
			}
			return near;
		}
		
		/**
		 * Returns the distance between this Entity and the specified Entity's hitboxes, when this is placed at the position.
		 * @param	entity	The Entity to calculate the distance from.
		 * @param	x		The x-position of this Entity.
		 * @param	y		The y-position of this Entity.
		 */
		public function distanceTo(e:Entity, x:int, y:int):Number
		{
			x -= originX;
			y -= originY;
			return FP.distanceRects(x, y, width, height, e.x - e.originX, e.y - e.originY, e.width, e.height);
		}
		
		/**
		 * @private a double-check called when collideBack == true, for Entities with special collision conditions.
		 */
		public function checkBack(entity:Entity, x:int, y:int):Boolean
		{
			return true;
		}
		
		// if checkBack() must be called when colliding against this Entity
		/** @private */ public var collideBack:Boolean = false;
		
		// Entity information and linked lists
		/** @private */ internal var _added:Boolean;
		/** @private */ internal var _depth:int = 0;
		/** @private */ internal var _updateNext:Entity;
		/** @private */ internal var _updatePrev:Entity;
		/** @private */ internal var _renderNext:Entity;
		/** @private */ internal var _renderPrev:Entity;
		/** @private */ internal var _collisionType:String;
		/** @private */ internal var _collisionNext:Entity;
		/** @private */ internal var _collisionPrev:Entity;
		/** @private */ internal var _class:String;
		/** @private */ internal var _recycleNext:Entity;
		
		// global objects
		private var _point:Point = FP.point;
		private var _point2:Point = FP.point2;
		private var _rect:Rectangle = FP.rect;
	}
}