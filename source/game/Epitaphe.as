package game 
{
	import net.flashpunk.Entity;
	import net.flashpunk.graphics.Text
	import net.flashpunk.FP;
	import net.flashpunk.utils.Draw;
	
	public class Epitaphe extends Entity
	{
		
/*		[Embed(source='../../assets/fonts/BMblock.TTF', fontFamily = 'block')]
		private static const FONT:Class;
*/		
		[Embed(source='../../assets/fonts/ARIAL.TTF', fontFamily = 'quote')]
		private static const FONT:Class;
		
		
		private var _SYLLOGISME:String;
		private var _showOnlyThatMuch:String;
		private var _lengthToDisplay:uint = 0;
		
		public var supportSyllogisme:Text = new Text("", 0, 0, 4000, 100);
		
		public function Epitaphe() 
		{
			this.y = 200;
			
			layer = 0;
			
			supportSyllogisme.font = "quote";
			supportSyllogisme.size = 36;
			supportSyllogisme.color = 0x6BA432;
			
			graphic = supportSyllogisme;
			
			_SYLLOGISME = LoadXmlData.CITATION;
			
		}
		
		override public function update():void 
		{
			_showOnlyThatMuch = _SYLLOGISME.slice(0, _lengthToDisplay);
			supportSyllogisme.text = _showOnlyThatMuch;
			//trace(supportSyllogisme.text);
			super.update();
		}
		
		
		public function unravelFinalWord(length:uint):void
		{
			_lengthToDisplay = length;
		}
		
	}

}