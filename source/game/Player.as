package game 
{
	import flash.display.Sprite;
	import flash.geom.Point;
	import net.flashpunk.graphics.Emitter;
	import net.flashpunk.graphics.Graphiclist;
	import net.flashpunk.graphics.Image;
	import net.flashpunk.graphics.ParticleType;
	import net.flashpunk.graphics.Spritemap;
	import net.flashpunk.tweens.misc.*;
	import net.flashpunk.tweens.motion.LinearMotion;
	import net.flashpunk.utils.Ease;
	import net.flashpunk.utils.Input;
	import net.flashpunk.utils.Key;
	import game.LoadXmlData;

	
	import net.flashpunk.*;
	
	public class Player extends Moveable
	{
		/**
		 * Player graphic.
		 */
		[Embed(source = '../../assets/spritesheetAvatar.png')] private const PLAYER:Class;
		public var father:Spritemap = new Spritemap(PLAYER, 30, 30);
		
		[Embed(source = '../../assets/spritesheetAvatarFils.png')] private const CHILD:Class;
		public var child:Spritemap = new Spritemap(CHILD, 30, 30);
		
		[Embed(source = '../../assets/spriteSheetGrandChild.png')] private const GRAND_CHILD:Class;
		public var grandChild:Spritemap = new Spritemap(GRAND_CHILD, 30, 30);
		
		/**
		 * Tweeners.
		 */
		public const SCALE:LinearMotion = new LinearMotion;
		//public const ROTATE:NumTween = new NumTween;
		
		/**
		 * Alarms.
		 */
		public var timeToChild:Alarm;
		public var timeFatherToChild:Alarm;
		public var timeToGrandChild:Alarm;
		
	
		/**
		 * Game (transmission) specific variables.
		 */
		//private const COEFF_D:Number = 2; // used in S-curve calculation		
		//public const VB:Number = 0.3; // base speed of father
		//public const CT_VB:Number = 0.2; // Ctvb : coeff de transmission de la vitesse de base father -> child
		
		public var COEFF_D:Number; // used in S-curve calculation		
		public var VB:Number; // base speed of father
		public var CT_VB:Number; // Ctvb : coeff de transmission de la vitesse de base father -> child
		public var D_MAX:Number; // max distance used in mapping for s-curve data
		public var S_MIN:Number; // s-cruve mini abcisse
		public var S_MAX:Number; // s-cruve max abcisse
					
		/**
		 * Movement variables.
		 */
		public var previousPos:Point; // store previous player position
		public var pathIndex:uint; // stores an index to target the required path when calling an array
		public var distance:Number = 0; // stores frame by frame distance
		public var vbArray:Array;
		
		public var moveHistory:Vector.<Point> = new Vector.<Point>(); // List<Point> to store player move history
		private var moveIndex:uint;
		
				
		public var animatedTile:PathTile;
		public var pathTileList:Vector.<PathTile> = new Vector.<PathTile>(); // List<PathTile> to store animated tiles
		public var row:int, col:int; 
		
		/**
		 * Player state.
		 */
		public var state:String = "father";
		
		/**
		 * Animation properties.
		 */
		public var frames:Array;
		
		/**
		 * define hitbox origin.
		 */		
		private var offsetOriginX:int;
		private var offsetOriginY:int;
		
		/**
		 * Movement constants.
		 */
		//public const ACCELX:Number = 1000;
		//public const ACCELY:Number = 1000;
		//public const DRAG:Number = 800;
				
		/**
		 * Movement properties.
		 */
		
		//public var spdX:Number = 0;
		//public var spdY:Number = 0;
		
		/**
		 * Particle emitter.
		 */
		//public var emitter:Emitter;
		
		public function Player(_x:int=0, _y:int=0, _vb:Array=null) 
		{
			this.x = _x;
			this.y = _y;
			
			// set position vector as entity's coordinates
			position.x = x;
			position.y = y;
			
			// set initial player position as first previousPos
			previousPos = position.clone();
			
			// set the Entity's graphic property to a Spritemap object
			graphic = father;
			frames = new Array( 0, 1, 2, 3 );
			father.add("walk", frames, 5, true);
			child.add("walk", frames, 5, true);
			grandChild.add("walk", frames, 5, true);
			
			// note: if you're goiing down the route of fixed framrate, use 
			// avatar.add("walk", frames, 5*(1/FP.frameRate), true);
			
			//hitbox based on image size
			
			// set hitbox origin at c. 2/5th right and 2/3rd down from entity origin
			offsetOriginX = -1.5*(father.width/5);
			offsetOriginY = -1.7*(father.height/3);
			// set hitbox width and height
			var boxWidth:int = father.width / 3;
			var boxHeight:int = father.height / 4;					
			setHitbox(boxWidth, boxHeight, offsetOriginX, offsetOriginY);
			
			/*
			TODO center the origin of the player
			avatar.originX = avatar.width / 2;
			avatar.originY = avatar.height / 2;
			avatar.x = -avatar.originX;
			avatar.y = -avatar.originY;
			avatar.smooth = true;
			
			addTween(SCALE);
			addTween(ROTATE);
			SCALE.x = SCALE.y = 1;
			*/
			
			
			// define payer movement keys
			Input.define("R", Key.RIGHT);
			Input.define("L", Key.LEFT);
			Input.define("U", Key.UP);
			Input.define("D", Key.DOWN);
			
			
			// Initialize
			// distance (0) on each path type
			for (var i:int = 0; i < 3; i++) 
			{
				pathDistance[i] = 0;
			}
			
			// initialize variables from gamedata.xml file
			COEFF_D = LoadXmlData.COEFF_D; // used in S-curve calculation		
			VB = LoadXmlData.VB; // base speed of father
			CT_VB = LoadXmlData.CT_VB; // Ctvb : coeff de transmission de la vitesse de base father -> child
			D_MAX = LoadXmlData.D_MAX;
			S_MIN = LoadXmlData.S_MIN;
			S_MAX = LoadXmlData.S_MAX;
			
			// and basic speed vb on each path (pathBaseSpeed is an array)
			vbArray = new Array(VB, VB, VB);
			if (_vb == null	) 
			{
				pathBaseSpeed = vbArray; //NOTE may have to concat() to make a true copy
			} 
			
			trace("player created");
		}
		
/*		override public function added():void 
		{
			emitter = (FP.world.classFirst(Particles) as Particles).emitter;
		}*/
		
		/**
		 * Update the player.
		 */
		override public function update():void 
		{
			pathIndex = getCurrentPath();
			
			// update speed on paths based on new pathDistance
			scurve();
			
			
			
			//check if a new animated tile needs to be placed where player has walked
			var shiftX:Number, shiftY:Number; // need to locate the center of the entity
			
			//shiftX = x + father.width / 2;
			//shiftY = y + father.height / 2;
			//addNewTile(shiftX, shiftY, 30); //TODO 30 is the grid step (move to property please!)
			
			shiftX = x - offsetOriginX;
			shiftY = y - offsetOriginY;
			addNewTile(shiftX, shiftY, 30);
			
			// move player based on maximum speeds returned by the s-curve
			acceleration(pathIndex);
			
			// calculate distance traveled since last frame and add to that path total
			distance = Point.distance(position, previousPos);
			pathDistance[pathIndex] += distance;
			
			// calculate distance traveled on all paths
			getTotalDistanceTravelled();
			
			// calculate ratios
			getPathRatios();
			
			// play sprite animation
			animation();
			
			//store current position as next previous position
			previousPos = position.clone();
			
			//store current player position in move hisotory 
			if (velocity.x!=0 || velocity.y!=0) 
			{
				moveIndex = moveHistory.push(previousPos);
				
				//pop oldest move history from List to keep only the last 10 moves
				if (moveIndex==60) 
				{
					moveHistory.shift();
				}
			//BUG: if player never moves, will get a rangeError. populate the List to player start position?
			}
			
			
			//trace (moveHistory.length);
		}
		
		public function addNewTile(_x:int, _y:int, _step:int ):void
		{
			// convert x,y into row, col
			var tileExists:Boolean = false;
			
			col = Math.floor(_x / _step);
			row = Math.floor(_y / _step);
			
			// loop through vector to see if a path of index (row,col) already exists
			for each (var value:PathTile in pathTileList)
			{
				if (value.row==row && value.col == col) 
				{
					tileExists = true;
					break;
				}				
			}
			//trace(tileExists);
			if (tileExists==false) 
			{
				// add new animated tile to Vector and Level
				var index:int = pathTileList.push(new PathTile(col, row, 30, pathIndex)); //TODO ditto: don't hardwire step
				//trace("path index: " + pathIndex);
				FP.world.add(pathTileList[index-1]);
			}
		}
		
		private function getTotalDistanceTravelled():void
		{
			var total:Number = 0;
			
			for (var i:int = 0; i < 3; i++) 
			{
				total += pathDistance[i];
			}
			
			totaldistance = total;
		}
		
		private function getPathRatios():void
		{
			for (var i:int = 0; i < 3; i++) 
			{
				pathDistToTotalRatio[i] = pathDistance[i] / totaldistance;
			}
				//trace(distance);
				//trace(pathDistance[pathIndex]);
		}
		
		/**
		 * Accelerates the player based on input.
		 */
		private function acceleration(pathType:uint):void
		{
			// evaluate input
			velocity.x = 0;
			velocity.y = 0;			
			var sign:int, e:Entity;
			
			
			if (Input.check("R"))
			{
				if ((e = collideTypes(pathCollideType, x + pathMaxVel[pathType], y)))
				{
					velocity.x = pathMaxVel[pathType];
				} else 
				{
					velocity.x = 0;
				}
				//trace("right");
			}
						
			if (Input.check("L"))
			{
				if ((e = collideTypes(pathCollideType, x - pathMaxVel[pathType], y)))
				{
					velocity.x = -pathMaxVel[pathType];
				} else 
				{
					velocity.x = 0;
				}	
				//trace("left");
				
			}
			
			if (Input.check("U"))
			{
				if ((e = collideTypes(pathCollideType, x, y - pathMaxVel[pathType])))
				{
					velocity.y = -pathMaxVel[pathType];
				} else 
				{
					velocity.y = 0;
				}
				//trace("up");
				
			}
			
			
			if (Input.check("D"))
			{
				if ((e = collideTypes(pathCollideType, x, y + pathMaxVel[pathType])))
				{
					velocity.y = +pathMaxVel[pathType];
				} else 
				{
					velocity.y = 0;
				}	
				//trace("down");

			}
			//trace("position: x=" + position.x + " y=" + position.y);
			//trace("velocity: x=" + velocity.x + " y=" + velocity.y);
			
			// add position to velocity vector
			position.x = (position.add(velocity)).x;
			position.y = (position.add(velocity)).y;
			
			// set new player x,y
			x = position.x;
			y = position.y;
			
			//trace("position: x=" + position.x + " y=" + position.y + "\n");
			
		}
		// end acceleration()
		
		/**
		 * S-curve calculation.
		 */
		private function scurve():void
		{			
			//maxSpeed[i] = avatar.speedBasePath[i] + avatar.coeff_d * ( 1 / (1 + exp(-adjust)))*avatar.coefSpeedBaseChild[i];   
			for (var i:int = 0; i < 3; i++) 
			{
				// first map distance on path to s-curve significant numbers
				var mapped:Number = FP.scale(pathDistance[i], 0, D_MAX, S_MIN, S_MAX);
				pathMaxVel[i] = pathBaseSpeed[i] + COEFF_D * (1 / (1 + Math.exp(-mapped)));
				
			}
			//trace("mapped: " + FP.scale(pathDistance[2], 0, 800, -3, -1) + " vb blue: " + pathBaseSpeed[2] + " maxVel blue : " + pathMaxVel[2]);
			//trace("base speed: " + pathBaseSpeed[i]);
			//trace("maxVel: " + pathMaxVel[i]);
		}
		
		/**
		 * Handles animation.
		 */
		private function animation():void
		{
			// switch to the correct Spritemap to play the animation
			var who:Spritemap;
			
			switch (state) 
			{
				case "father":
					who = father;
					break;
				case "childAlive":
					who = father;
					break;	
				case "child":
					who = child;
					break;
				case "grandChild":
					who = grandChild;
					break;	
			}
			
			if (velocity.x != 0 || velocity.y != 0)
			{
				who.play("walk");
			} else who.setFrame(0);
			
			// control facing direction
			//if (spdX != 0) avatar.flipped = spdX < 0;
			
			// avatar scale tweening
			//avatar.scaleX = SCALE.x;
			//avatar.scaleY = SCALE.y;
			
			// avatar rotation
			/*if (onSolid)
			{
				avatar.angle = 0;
				ROTATE.active = false;
				ROTATE.value = 0;
			}
			else avatar.angle = (spdX / MAXX) * 10 + ROTATE.value;*/
		}
		
		/**
		 * Horizontal collision handler.
		 */
		/*override protected function collideX(e:Entity):void 
		{
			if (spdX > 100 || spdX < -100) SCALE.setMotion(1, 1.2, 1, 1, .2, Ease.quadIn);
			spdX = 0;
		}*/
		
		/**
		 * Vertical collision handler.
		 */
		/*override protected function collideY(e:Entity):void 
		{
			if (spdY > 0)
			{
				SCALE.setMotion(1.2, 1, 1, 1, .2, Ease.quadIn);
				spdY = 0;
				spdX /= 2;
			}
			else
			{
				SCALE.setMotion(1.2, 1, 1, 1, .1, Ease.quadOut);
				spdY /= 2;
			}
		}*/
		
				/**
		 * Makes the player jump on input.
		 */
		/*private function jumping():void
		{
			if (onSolid && Input.pressed("JUMP"))
			{
				spdY = JUMP;
				onSolid = false;
				if (spdX < 0 && avatar.flipped) spdX *= LEAP;
				else if (spdX > 0 && !avatar.flipped) spdX *= LEAP;
				
				SCALE.setMotion(1, 1.2, 1, 1, .2, Ease.quadIn);
				ROTATE.tween(0, 360 * -FP.sign(spdX), FP.scale(Math.abs(spdX), 0, MAXX, .7, .5), Ease.quadInOut);
				
				var i:int = 10;
				while (i --) emitter.emit("dust", x - 10 + FP.rand(20) , y + 16);
			}
		}*/

	}
}