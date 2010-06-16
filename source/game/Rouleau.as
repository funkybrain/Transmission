package game 
{
	import net.flashpunk.Entity;
	import net.flashpunk.graphics.Anim;
	import net.flashpunk.graphics.Spritemap;
	import net.flashpunk.tweens.misc.NumTween;
	import net.flashpunk.utils.Ease;
	import net.flashpunk.FP;
	
	 
	public class Rouleau extends Entity
	{
		[Embed(source = '../../assets/spriteSheetRouleau.png')]
		private const ROULEAU:Class;
		
		public var spriteRouleau:Spritemap = new Spritemap(ROULEAU, 20, 480);
		
		private var _animation:Array = new Array(0, 1, 2, 3, 4, 5);
		
		public var previousX:int;
		
		/**
		* Properties
		*/
		private var _spinning:NumTween;
		private var _spinRate:NumTween;
		public var isSpinning:Boolean = false;
		public var inertieX:Number;
		
		/**
		 * Constructer
		 */
		public function Rouleau() 
		{
			this.graphic = spriteRouleau;
			
			layer = Layers.ROULEAU;
			
			_spinning = new NumTween(_onSpinComplete);
			_spinRate = new NumTween();
			addTween(_spinning);
			addTween(_spinRate);
			
			inertieX = 0;
			
			type = "rouleau";
			width = 20;
			height = 480;
			
			// start rolling animation
			playAnimation();
		}
		
		public function playAnimation():void
		{
			spriteRouleau.add("roule", _animation, 24, true);
			spriteRouleau.play("roule");
		}
		
		public function rollFree():void
		{
			var tweenTime:Number = 3;
			inertieX = 0;
			
			_spinning.tween(0, 40, tweenTime, Ease.cubeOut);
			_spinRate.tween(1, 0, tweenTime);
			_spinning.start();
			_spinRate.start();
			
			isSpinning = true;
			
			
		}
		
		private function _onSpinComplete():void
		{
			isSpinning = false;
			//trace("free roll complete");
		}
		
		override public function update():void 
		{
			if (_spinning.active) 
			{
				inertieX = _spinning.value;
				
				spriteRouleau.rate = _spinRate.value;
			}
			
			// store the position before the update, so that you can compare with current position in Game update()
			if (x > previousX) 
			{
				previousX = x;
			}
			
			super.update();
		}
		
	}

}