package game 
{
	import flash.net.URLLoader
	import flash.net.URLRequest
	import flash.xml.*
	import flash.errors.*
	import flash.events.*
	import net.flashpunk.FP;
	import net.flashpunk.World;
	import rooms.Level;

	
	/**
	* Constructor 
	*/
	public class LoadXmlData
	{
		public var gameData:XML;
		public var loader:URLLoader = new URLLoader();
		public var url:XMLList;
		
		public static var gameDataLoaded:Boolean = false;
		
		public static var timer_ToChild:Number;
		public static var timer_GrandChildToEnd:Number;
		public static var timer_FatherToChild:Number;
		public static var timer_FatherToDeath:Number;
		public static var timer_ChildToGrandChild:Number;
		
		public static var COEFF_D:Number;
		public static var COEFF_D_CHILD:Number;
		public static var COEFF_D_GRANDCHILD:Number;
		
		public static var D_MAX:Number;	
		public static var S_MIN:Number;	
		public static var S_MAX:Number;				
		public static var VB:Number;
		public static var CT_VB:Number;
		public static var DEBUG:Boolean;
		public static var GODMODE:Boolean;
		public static var LD:Boolean;
		
		public static var CITATION:String;
		
		public static var VOLUME:Number;
		public static var HUD:Boolean;
		
		public static var TRANS_TIMER:Number;
		
		public function LoadXmlData() 
		{
			loader.addEventListener(Event.COMPLETE, onComplete);
			loader.load(new URLRequest("gamedata.xml"));
		}
		
		public function onComplete(evt:Event):void
		{
			gameData = new XML(loader.data)
			trace("xml loaded, start parsing using E4X syntax");
			
			// speed
			VB = Number(gameData.vitesse.VB.text());
			CT_VB = Number(gameData.vitesse.CT_VB.text());
			
			// scurve
			COEFF_D = Number(gameData.scurve.COEFF_D.text());
			COEFF_D_CHILD = Number(gameData.scurve.COEFF_D_CHILD.text());
			COEFF_D_GRANDCHILD = Number(gameData.scurve.COEFF_D_GRANDCHILD.text());
			
			D_MAX = Number(gameData.scurve.D_MAX.text()); 
			S_MIN = Number(gameData.scurve.S_MIN.text());
			S_MAX = Number(gameData.scurve.S_MAX.text());
			
			// timers
			timer_ToChild = Number(gameData.timers.timeToChild.text());
			timer_FatherToDeath = Number(gameData.timers.timeFatherToDeath.text());
			timer_FatherToChild = Number(gameData.timers.timeFatherToChild.text());
			timer_ChildToGrandChild = Number(gameData.timers.timeChildToGrandChild.text());
			timer_GrandChildToEnd = Number(gameData.timers.timeGrandChildToEnd.text());
			
			// debug
			DEBUG = stringToBoolean(gameData.debug.text());
			GODMODE = stringToBoolean(gameData.godmode.text());
			LD = stringToBoolean(gameData.LD.text());
		
			// citation
			CITATION = gameData.citation.text(); 
			
			//volume
			VOLUME = Number(gameData.volume.text());
			
			//transmition timer
			TRANS_TIMER = Number(gameData.transmitTimer.text());
			
			// HUD
			HUD = stringToBoolean(gameData.HUD.text());
			
			trace("done assigning data in LoadXmlData");

			//trace("starting intro movie");
			//remove comment to play intro movie
			
			//var playIntro:Intro = new Intro();

			//trace("creating world");			
			// comment out to pplay intro movie
			
			FP.world = new Game;
			
		}
		
		
		// helper function
		public static function stringToBoolean($string:String):Boolean
		{
		
          return ($string.toLowerCase() == "true" || $string.toLowerCase() == "1");
		
		}


		
	}

}