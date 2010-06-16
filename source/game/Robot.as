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
		[Embed(source = '../../assets/spriteSheetFatherDeath.png')] private const R_FATHER_DEATH:Class;
		public var robotFatherDeath:Spritemap = new Spritemap(R_FATHER_DEATH, 30, 30, onFatherDeathComplete);
				
		[Embed(source = '../../assets/spriteSheetAutoAccouchement.png')] private const R_DAUGHTER_DEATH:Class;
		public var robotDaughterDeath:Spritemap = new Spritemap(R_DAUGHTER_DEATH, 60, 30, onDaughterDeathComplete);
		
		/**
		 * Animation properties.
		 */
		
		public var framesFatherDeath:Array;
		public var framesDaughterDeath:Array;
		
		/**
		 * Robot properties
		 */
		public var state:String;
		public var remove:Boolean = false;
			 
		public function Robot(_x:Number, _y:Number, _state:String) 
		{
			this.x = _x;
			this.y = _y;
			
			// layer
			layer = Layers.ROBOT;
			
			// offset graphics so that they are centered around entity's origin
			robotFatherDeath.x = -15;
			robotFatherDeath.y = -15;
						
			robotDaughterDeath.x = -15;
			robotDaughterDeath.y = -15;
			
			type = "robot";
			
			state = _state;
						
			framesFatherDeath = new Array(0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13);
			framesDaughterDeath = new Array(0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18,
				19, 20, 21, 22, 23, 24, 25);
				
			// set the Entity's graphic property to a Spritemap object
			setSprite();
			
		}
		
		public function setSprite():void
		{
			if (state=="robotdaughter") 
			{
				graphic = robotDaughterDeath;
				robotDaughterDeath.add("push", framesDaughterDeath, 2, false);
			} else {
				graphic = robotFatherDeath;
				robotFatherDeath.add("die", framesFatherDeath, 2, false);
			}
			
			// horrible hack to align daughter between sprites
			var adjust:VarTween = new VarTween(null, 2);
			adjust.tween(this, "y", y - 5, 2);
			addTween(adjust, true);
		}
		
		/**
		 * event handler once father death animation has stopped playing
		 */
		public function onFatherDeathComplete():void
		{
			var fadeTween:VarTween = new VarTween(onFadeComplete, 2);
			fadeTween.tween(this.robotFatherDeath, "alpha", 0, 10, Ease.backOut);
			addTween(fadeTween);
			fadeTween.start();
		}
		
		public function onDaughterDeathComplete():void
		{
			var fadeTween:VarTween = new VarTween(onFadeComplete, 2);
			fadeTween.tween(this.robotDaughterDeath, "alpha", 0, 10, Ease.backOut);
			addTween(fadeTween);
			fadeTween.start();
		}
		
		private function onFadeComplete():void
		{
			remove = true;
		}
		
		
		
	}

}