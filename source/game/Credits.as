package game 
{
	
	public class Credits extends Intro
	{
	
		[Embed(source='../../assets/creditsTransmission.swf', symbol='wrapper')]
		private var _movie:Class;
		
		public function Credits() 
		{
			super();
		}
		
		override public function init(_clip:Class):void 
		{
			super.init(_movie);
		}
		
	}

}