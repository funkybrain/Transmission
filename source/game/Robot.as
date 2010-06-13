package game 
{
	import flash.geom.Point;
	import net.flashpunk.Entity;
	import net.flashpunk.graphics.*;
	import net.flashpunk.FP;
	import net.flashpunk.tweens.misc.VarTween;
	import net.flashpunk.utils.Ease;
	
	/**
	 * Robot class is controlled by AI 
	 */
	
	public class Robot extends Moveable
	{
		/**
		 * Player graphic.
		 */
/*		[Embed(source = '../../assets/spritesheetChild.png')] private const ROBOT_CHILD:Class;
		public var robotChild:Spritemap = new Spritemap(ROBOT_CHILD, 30, 30);
		
		[Embed(source = '../../assets/spritesheetFather.png')] private const ROBOT_FATHER:Class;
		public var robotFather:Spritemap = new Spritemap(ROBOT_FATHER, 30, 30);*/
		
		[Embed(source = '../../assets/spriteSheetFatherDeath.png')] private const ROBOT_DEATH:Class;
		public var robotDeath:Spritemap = new Spritemap(ROBOT_DEATH, 30, 30, onRobotDeathComplete);
		
		/**
		 * Animation properties.
		 */
		//public var frames:Array;
		public var framesRobotDeath:Array;
		
		/**
		 * Robot properties
		 */
		public var state:String;
		
			 
		public function Robot(_x:Number, _y:Number, _state:String) 
		{
			this.x = _x;
			this.y = _y;
			
			// layer
			layer = 6;
			
			// offset graphics so that they are centered around entity's origin
			robotDeath.x = -15;
			robotDeath.y = -15;
			
			type = "robot";
			
			state = _state;
						
			framesRobotDeath = new Array(0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13);
			
			// set the Entity's graphic property to a Spritemap object
			setSprite();
			
		}
		
		public function setSprite():void
		{
			if (state=="robotchild") 
			{
				/*graphic = robotChild;
				robotChild.add("walk", frames, 12, true);
				robotChild.scale = 0.5;*/
			} else {
				graphic = robotDeath;
				robotDeath.add("die", framesRobotDeath, 2, false);
			}
			
			// horrible hack to align daughter between sprites
			var adjust:VarTween = new VarTween(null, 2);
			adjust.tween(this, "y", y - 5, 2);
			addTween(adjust, true);
		}
		
		/**
		 * event handler once father death animation has stopped playing
		 */
		public function onRobotDeathComplete():void
		{
			var fadeTween:VarTween = new VarTween(onFadeComplete, 2);
			fadeTween.tween(this.robotDeath, "alpha", 0, 10, Ease.backOut);
			addTween(fadeTween);
			fadeTween.start();
			
			
		}
		
		private function onFadeComplete():void
		{
			FP.world.remove(this);
			trace("removed robot from world");
		}
		
		
		
	}

}