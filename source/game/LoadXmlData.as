package game 
{
	import flash.net.URLLoader
	import flash.net.URLRequest
	import flash.xml.*
	import flash.errors.*
	import flash.events.*
	
	public class LoadXmlData
	{
		public var gameData:XML;
		public var loader:URLLoader = new URLLoader();
		public var url:XMLList;
		
		
		public static var timer_ToChild:Number;
		public static var timer_ToGrandChild:Number;
		public static var timer_FatherToChild:Number;
		public static var timer_ChildToGrandChild:Number;
		public static var COEFF_D:Number;	
		public static var D_MAX:Number;	
		public static var S_MIN:Number;	
		public static var S_MAX:Number;				
		public static var VB:Number;
		public static var CT_VB:Number;
		
		public function LoadXmlData() 
		{
			loader.addEventListener(Event.COMPLETE, onComplete);
			loader.load(new URLRequest("../data/gamedata.xml"));
		}
		
		public function onComplete(evt:Event):void
		{
			gameData = new XML(loader.data)
			//trace("xml loaded, start parsing using E4X syntax");
			
			// speed
			VB = Number(gameData.vitesse.VB.text());
			CT_VB = Number(gameData.vitesse.CT_VB.text());
			
			// scurve
			COEFF_D = Number(gameData.scurve.COEFF_D.text());
			D_MAX = Number(gameData.scurve.D_MAX.text()); 
			S_MIN = Number(gameData.scurve.S_MIN.text());
			S_MAX = Number(gameData.scurve.S_MAX.text());
			
			// timers
			timer_ToChild = Number(gameData.timers.timeToChild.text());
			timer_ToGrandChild = Number(gameData.timers.timeToGrandChild.text());
			timer_FatherToChild = Number(gameData.timers.timeFatherToChild.text());
			timer_ChildToGrandChild = Number(gameData.timers.timeChildToGrandChild.text());
						
		}
		
	}

}