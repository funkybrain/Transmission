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
		public const VMAX:Number = 100;
		//public const MAXY:Number = 800;
		//public const GRAV:Number = 1500;
		//public const FLOAT:Number = 3000;
		public const ACCELX:Number = 1200;
		public const ACCELY:Number = 1200;
		public const DRAG:Number = 800;
		//public const JUMP:Number = -500;
		//public const LEAP:Number = 1.5;
		
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
		
		public function Player(x:int = 30, y:int = 30) 
		{
			this.x = x;
			this.y = y;
			
			// set the Entity's graphic property to a Spritemap object
			graphic = avatar;
			frames = new Array( 0, 1, 2, 3 );
			avatar.add("walk", frames, 5, true);
			
			setHitbox(30, 30);
			
			//TODO might need at a letter point to center the origin of the player
			//avatar.originX = avatar.width / 2;
			//avatar.originY = avatar.height / 2;
			//avatar.x = -avatar.originX;
			//avatar.y = -avatar.originY;
			//avatar.smooth = true;

			//addTween(SCALE);
			//addTween(ROTATE);
			//SCALE.x = SCALE.y = 1;
			
			Input.define("R", Key.RIGHT);
			Input.define("L", Key.LEFT);
			Input.define("U", Key.UP);
			Input.define("D", Key.DOWN);
			
			//Input.define("JUMP", Key.SPACE, Key.SHIFT, Key.CONTROL, Key.UP, Key.Z, Key.X, Key.A, Key.S);
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
			//checkFloor();
			//gravity();
			acceleration();
			//jumping();
			move(spdX * FP.elapsed, spdY * FP.elapsed);
			animation();
			
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
		private function acceleration():void
		{
			// evaluate input
			var accelx:Number = 0;
			var accely:Number = 0;
			
			if (Input.check("R")) accelx += ACCELX;
			if (Input.check("L")) accelx -= ACCELX;
			if (Input.check("U")) accely -= ACCELY;
			if (Input.check("D")) accely += ACCELY;
			
			// handle acceleration
			if (accelx != 0)
			{
				if (accelx > 0)
				{
					// accelerate right
					if (spdX < VMAX)
					{
						spdX += accelx * FP.elapsed;
						if (spdX > VMAX) spdX = VMAX;
					}
					else accelx = 0;
				} else	{
					// accelerate left
					if (spdX > -VMAX)
					{
						spdX += accelx * FP.elapsed;
						if (spdX < -VMAX) spdX = -VMAX;
					}
					else accelx = 0;
				}
			
			}	

			
			// handle acceleration
			if (accely != 0)
			{
				if (accely > 0)
				{
					// accelerate down
					if (spdY < VMAX)
					{
						spdY += accely * FP.elapsed;
						if (spdY > VMAX) spdY = VMAX;
					}
					else accely = 0;
				}
				else
				{
					// accelerate up
					if (spdY > -VMAX)
					{
						spdY += accely * FP.elapsed;
						if (spdY < -VMAX) spdY = -VMAX;
					}
					else accely = 0;
				}
			
			}
			
			// handle decelleration
			if (accelx == 0)
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
			
			if (accely == 0)
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
		override protected function collideX(e:Entity):void 
		{
			if (spdX > 100 || spdX < -100) SCALE.setMotion(1, 1.2, 1, 1, .2, Ease.quadIn);
			spdX = 0;
		}
		
		/**
		 * Vertical collision handler.
		 */
		override protected function collideY(e:Entity):void 
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
		}
	}
}