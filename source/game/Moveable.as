﻿package game 
{
	import flash.geom.Point;
	import net.flashpunk.Entity;
	import net.flashpunk.FP;
	
	/**
	 * Base class for moving Entities to handle collision.
	 */
	public class Moveable extends Entity
	{
		/**
		 * Entity -type- to consider solid when colliding.
		 */
		public var pathCollideType:Array = new Array("red", "green", "blue");
		
		
		/**
		 * Movement variables.
		 */

		public var position:Point; // position vector of player
		public var velocity:Point; // velocity vector of player
		
		/**
		 * Game (transmission) specific variables.
		 */
		public var pathBaseSpeed:Array = new Array(); // basic speed modifier on each path
		public var pathMaxVel:Array = new Array(); // max velocity on each path type
		public var pathInstantVel:Array = new Array(); // the actual velocity used in all movement calculations		
		public var pathFastest:Number; // the maximum speed of all paths
		
		public var totaldistance:Number=0; // total distance traveled on all paths
		public var pathDistance:Array = new Array(); // distance travelled on each path
		public var pathDistToTotalRatio:Array = new Array(0,0,0); // ratio of distance travelled on each path by total distance
		 
		/**
		 * Constructor.
		 */
		public function Moveable() 
		{
			//type = "player";
			
			position = new Point(); // set initial position to zero
			velocity = new Point(); // set intial velocity to zero
		}
		
		/**
		 * getCurrentType finds out what path the player is standing on,
		 * and returns the value of that path (uint) that will be used in
		 * e.g. pathMaxVel[] array 
		 */
		
		 //BUG got scarry bug right here, not reproduceable
		 // use a throw statement?
		public function getCurrentPath():uint
		{
			var e:Entity, pathType:uint;
			e = collideTypes(pathCollideType, x, y);
			
			//trace("collision type: " + e.type);
			
			if (e == null) 
			{
				trace("no collision detected in Moveable.getCurentPath");
				trace("player position x:" + x + " y: " + y);
				
				return 3; // test for 3 to try and get debug information
			}
			else
			{
				switch (e.type)
				{
				case "red":
					pathType = 0;
					break;
				case "green":
					pathType = 1;
					break;
				case "blue":
					pathType = 2;
					break;
				}
			
				return pathType;
			}
		}
		
		public function getPathTypeAt(pos_x:Number, pos_y:Number):uint
		{
			var e:Entity, pathType:uint;
			e = collideTypes(pathCollideType, pos_x, pos_y);
			
			//trace("collision type: " + e.type);
			
			if (e == null) 
			{
				trace("no collision detected in Moveable.getCurentPath");
				trace("player position x:" + x + " y: " + y);
				
				return 3; // test for 3 to try and get debug information
			}
			else
			{
				switch (e.type)
				{
				case "red":
					pathType = 0;
					break;
				case "green":
					pathType = 1;
					break;
				case "blue":
					pathType = 2;
					break;
				}
			
				return pathType;
			}
		}

	}
}