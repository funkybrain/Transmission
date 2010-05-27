package game 
{
	import net.flashpunk.Entity;
	import net.flashpunk.graphics.Anim;
	import net.flashpunk.graphics.Spritemap;
	
	public class Rouleau extends Entity
	{
		[Embed(source = '../../assets/spriteSheetRouleau.png')]
		private const ROULEAU:Class;
		
		public var spriteRouleau:Spritemap = new Spritemap(ROULEAU, 20, 480);
		
		private var _animation:Array = new Array(0, 1, 2, 3, 4, 5, 6, 7, 8, 9);
		
		public var previousX:int;
		
		public function Rouleau() 
		{
			this.graphic = spriteRouleau;
			
			this.layer = 0;
			
			
			playAnimation();
		}
		
		public function playAnimation():void
		{
			spriteRouleau.add("roule", _animation, 24, true);
			spriteRouleau.play("roule");
		}
		
		override public function render():void 
		{
			// store the position before the update, so that you can compare with current position in Game update()
			previousX = x;
			
			super.render();
		}
		
	}

}