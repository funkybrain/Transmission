package game 
{
	import net.flashpunk.Entity;
	import net.flashpunk.graphics.Text
	import net.flashpunk.FP;
	
	public class Epitaphe extends Entity
	{
		
		[Embed(source='../../assets/fonts/BMblock.TTF', fontFamily = 'block')]
		private static const FONT:Class;
		
		private const _SYLLOGISME:String = "L'homme face à son désoeuvrement choisi le suicide plûtot de la Nintendo DS";
		private var _showOnlyThatMuch:String;
		private var _lengthToDisplay:uint;
		
		public var supportSyllogisme:Text = new Text("die pig", 0, 0, 800, 480);
		
		public function Epitaphe() 
		{
			this.y = 200;
			this.x = FP.camera.x;
			layer = 0;
			supportSyllogisme.font = "block";
			supportSyllogisme.size = 24;
			graphic = supportSyllogisme;
			
			trace("finalwords added");
		}
		
		override public function update():void 
		{
			_showOnlyThatMuch = _SYLLOGISME.slice(0, _lengthToDisplay);
			
			supportSyllogisme.text = _showOnlyThatMuch;
			
			super.update();
		}
		
		public function unravelFinalWord(length:uint):void
		{
			_lengthToDisplay = length;
		}
		
	}

}