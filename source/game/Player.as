package game 
{
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

	
	import net.flashpunk.*;
	
	public class Player extends Moveable
	{
		/**
		 * Player graphic.
		 */
		[Embed(source = '../../assets/spritesheetAvatar.png')] private const PLAYER:Class;
		public var avatar:Spritemap = new Spritemap(PLAYER, 30, 30);
		
		/**
		 * Tweeners.
		 */
		public const SCALE:LinearMotion = new LinearMotion;
		//public const ROTATE:NumTween = new NumTween;
		
		/**
		 * Alarms.
		 */
		//TODO gamedata to replace from xml
		public var timeToChild:Alarm;
		public var timeToGrandson:Alarm;
		
	
		/**
		 * Game (transmission) specific variables.
		 */
		private const COEFF_D:Number = 2; // used in S-curve calculation		
		public const VB:Number = 0.3; // base speed of father
		public const CT_VB:Number = 0.2; // Ctvb : coeff de transmission de la vitesse de base father -> child
		
					
		/**
		 * Movement variables.
		 */
		public var previousPos:Point; // store previous player position
		public var pathIndex:uint; // stores an index to target the required path when calling an array
		public var distance:Number = 0; // stores frame by frame distance
		public var vbArray:Array = new Array(VB, VB, VB);

		
		/**
		 * Animation properties.
		 */
		public var frames:Array;
		
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
			graphic = avatar;
			frames = new Array( 0, 1, 2, 3 );
			avatar.add("walk", frames, 5, true);
			// note: if you're goiing down the route of fixed framrate, use 
			// avatar.add("walk", frames, 5*(1/FP.frameRate), true);
			
			//TODO: transformations to set the hitbox based on image size
			
			// set hitbox origin at c. 2/5th right and 2/3rd down from entity origin
			var offsetOriginX:int = -1.5*(avatar.width/5);
			var offsetOriginY:int = -1.7*(avatar.height/3);
			// set hitbox width and height
			var boxWidth:int = avatar.width / 3;
			var boxHeight:int = avatar.height / 4;					
			setHitbox(boxWidth, boxHeight, offsetOriginX, offsetOriginY);
			
			//TODO center the origin of the player
			//avatar.originX = avatar.width / 2;
			//avatar.originY = avatar.height / 2;
			//avatar.x = -avatar.originX;
			//avatar.y = -avatar.originY;
			//avatar.smooth = true;
			
			//addTween(SCALE);
			//addTween(ROTATE);
			//SCALE.x = SCALE.y = 1;
			
			
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
			// and basic speed vb on each path (pathBaseSpeed is an array)
			if (_vb == null	) 
			{
				pathBaseSpeed = vbArray; //NOTE may have to concat() to make a true copy
			} 

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
			
			previousPos = position.clone(); //store current position as next previous position
			
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
		private function scurve():void //TODO s-curves are here
		{			
			//maxSpeed[i] = avatar.speedBasePath[i] + avatar.coeff_d * ( 1 / (1 + exp(-adjust)))*avatar.coefSpeedBaseChild[i];   
			for (var i:int = 0; i < 3; i++) 
			{
				// first map distance on path to s-curve significant numbers
				var mapped:Number = FP.scale(pathDistance[i], 0, 1000, -3, -1);
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
			if (velocity.x != 0 || velocity.y != 0)
			{
				avatar.play("walk");
			} else avatar.setFrame(0);
			
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