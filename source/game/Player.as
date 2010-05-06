package game 
{
	import flash.geom.Point;
	import net.flashpunk.graphics.Emitter;
	import net.flashpunk.graphics.Graphiclist;
	import net.flashpunk.graphics.Image;
	import net.flashpunk.graphics.ParticleType;
	import net.flashpunk.graphics.Spritemap;
	import net.flashpunk.tweens.misc.NumTween;
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
		 * Movement constants.
		 */
		public const ACCELX:Number = 1200;
		public const ACCELY:Number = 1200;
		public const DRAG:Number = 800;
		
		/**
		 * Movement variables.
		 */
		public var previousPos:Point; // store previous player position
		public var pathIndex:uint; // stores an index to target the required path when calling an array
		public var distance:Number = 0; // stores frame by frame distance

		/**
		 * Game (transmission) specific variables.
		 */
		public const COEFF_D:Number = 10; // used in S-curve calculation		
		 
		//public const JUMP:Number = -500;
		//public const LEAP:Number = 1.5;
		//public const MAXY:Number = 800;
		//public const GRAV:Number = 1500;
		//public const FLOAT:Number = 3000;
		
		/**
		 * Movement properties.
		 */
		public var onSolid:Boolean;
		public var spdX:Number = 0;
		public var spdY:Number = 0;
		
		/**
		 * Animation properties.
		 */
		public var frames:Array;
		 
		/**
		 * Particle emitter.
		 */
		//public var emitter:Emitter;
		
		public function Player(x:int, y:int, baseSpeed:Array) 
		{
			this.x = x;
			this.y = y;
			position.x = x;
			position.y = y;
			previousPos = position.clone(); // set initial player position as first previousPos
			
			// set the Entity's graphic property to a Spritemap object
			graphic = avatar;
			frames = new Array( 0, 1, 2, 3 );
			avatar.add("walk", frames, 5, true);
			
			// transformations to set the hitbox based on image size
			var offsetOriginX:int = -avatar.width / 4;
			var offsetOriginY:int = -avatar.height / 4;
			var boxWidth:int = avatar.width / 2;
			var boxHeight:int = avatar.height / 2;
						
			setHitbox(boxWidth, boxHeight, offsetOriginX, offsetOriginY);
			
			//TODO might need at a letter point to center the origin of the player
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
			
			/**
			 * Initialize:
			 * player maximum velocity (100)
			 * distance (0) on each path type
			 * basic speed on each path
			 */
			for (var i:int = 0; i < 3; i++) 
			{
				pathMaxVel[i] = 100;
				pathDistance[i] = 0;
			}
			
			pathBaseSpeed = baseSpeed; //NOTE may have to concat() to make a true copy
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
			acceleration(pathIndex);			
			move(spdX * FP.elapsed, spdY * FP.elapsed);
			
			// calculate distance traveled since last frame and add to path total
			distance = Point.distance(position, previousPos);
			pathDistance[pathIndex] += Math.round(distance);
			
			// update speed on paths based on new pathDistance
			scurve();
			
			//trace(distance);
			animation();
			previousPos = position.clone(); //store current position as next previous position
			
			if (Debug.flag==true) 
			{
				for (var i:int = 0; i < pathDistance.length; i++) 
				{
					trace("path: " + i + " dist: " + pathDistance[i]);
				}
			}
			
			//trace("spdX*elapsed: "+spdX * FP.elapsed);
			//if (spdY != 0) emitter.emit("trail", x - 10 + FP.rand(20), y - 10 + FP.rand(20));
		}
		
/*		private function checkFloor():void
		{
			if (collide(solid, x, y + 1)) onSolid = true;
			else onSolid = false;
		}*/
		
		/**
		 * Applies gravity to the player.
		 */
	/*	private function gravity():void
		{
			if (onSolid) return;
			var g:Number = GRAV;
			if (spdY < 0 && !Input.check("JUMP")) g += FLOAT;
			spdY += g * FP.elapsed;
			if (spdY > MAXY) spdY = MAXY;
		}*/
		
		/**
		 * Accelerates the player based on input.
		 */
		private function acceleration(pathType:uint):void
		{
			// evaluate input
			var accelx:Number = 0;
			var accely:Number = 0;
			
			if (Input.check("R")) accelx += ACCELX;
			if (Input.check("L")) accelx -= ACCELX;
			if (Input.check("U")) accely -= ACCELY;
			if (Input.check("D")) accely += ACCELY;
			
			// handle horizontal acceleration
			if (accelx != 0)
			{
				if (accelx > 0)
				{
					// accelerate right
					if (spdX < pathMaxVel[pathType])
					{
						spdX += accelx * FP.elapsed;
						if (spdX > pathMaxVel[pathType]) spdX = pathMaxVel[pathType];
					}
					else accelx = 0;
				} else	{
					// accelerate left
					if (spdX > -pathMaxVel[pathType])
					{
						spdX += accelx * FP.elapsed;
						if (spdX < -pathMaxVel[pathType]) spdX = -pathMaxVel[pathType];
					}
					else accelx = 0;
				}
			
			}	

			
			// handle vertical acceleration
			if (accely != 0)
			{
				if (accely > 0)
				{
					// accelerate down
					if (spdY < pathMaxVel[pathType])
					{
						spdY += accely * FP.elapsed;
						if (spdY > pathMaxVel[pathType]) spdY = pathMaxVel[pathType];
					}
					else accely = 0;
				}
				else
				{
					// accelerate up
					if (spdY > -pathMaxVel[pathType])
					{
						spdY += accely * FP.elapsed;
						if (spdY < -pathMaxVel[pathType]) spdY = -pathMaxVel[pathType];
					}
					else accely = 0;
				}
			
			}
			
			// handle decelleration (drag)
			if (accelx == 0) // horizontal drag
			{
				if (spdX > 0)
				{
					spdX -= DRAG * FP.elapsed;
					if (spdX < 0) spdX = 0;
				}
				else
				{
					spdX += DRAG * FP.elapsed;
					if (spdX > 0) spdX = 0;
				}
			}
			
			if (accely == 0) //vertical drag
			{
				if (spdY > 0)
				{
					spdY -= DRAG * FP.elapsed;
					if (spdY < 0) spdY = 0;
				}
				else
				{
					spdY += DRAG * FP.elapsed;
					if (spdY > 0) spdY = 0;
				}
			}
			
		}
		// end acceleration()
		
		/**
		 * S-curve calculation.
		 */
		private function scurve():void //BUG s-curve calcs are fucked
		{			
			//maxSpeed[i] = avatar.speedBasePath[i] + avatar.coeff_d * ( 1 / (1 + exp(-adjust)))*avatar.coefSpeedBaseChild[i];   
			for (var i:int = 0; i < 3; i++) 
			{
				// first map distance on path to s-curve significant numbers
				var mapped:Number = FP.scale(pathDistance[i], 0, 800, -3, -1);
				//trace(mapped);
				//trace(pathBaseSpeed[i]);
				pathMaxVel[i] = pathBaseSpeed[i] + COEFF_D * (1 / (1 + Math.exp(-mapped)));
				trace(pathMaxVel[i]);
			}
		}
		
		/**
		 * Handles animation.
		 */
		private function animation():void
		{
			if (spdX != 0 || spdY != 0)
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