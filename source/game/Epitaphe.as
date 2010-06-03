package game 
{
	import net.flashpunk.Entity;
	import net.flashpunk.graphics.Text
	import net.flashpunk.FP;
	import net.flashpunk.utils.Draw;
	
	public class Epitaphe extends Entity
	{
		
		[Embed(source='../../assets/fonts/BMblock.TTF', fontFamily = 'block')]
		private static const FONT:Class;
		
		private var _SYLLOGISME:String;
		private var _showOnlyThatMuch:String;
		private var _lengthToDisplay:uint;
		
		public var supportSyllogisme:Text = new Text("", 0, 0, 4000, 100);
		
		public function Epitaphe() 
		{
			this.y = 200;
			this.x = FP.camera.x;
			layer = 0;
			supportSyllogisme.font = "block";
			supportSyllogisme.size = 36;
			supportSyllogisme.color = 0x6BA432;
			graphic = supportSyllogisme;
			
			_SYLLOGISME = LoadXmlData.CITATION;
			
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