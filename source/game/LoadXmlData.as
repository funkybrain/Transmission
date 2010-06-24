package game 
{

	import net.flashpunk.FP;
	import net.flashpunk.World;
	
	/**
	* Constructor 
	*/
	public class LoadXmlData
	{

		
		public static var timer_ToChild:Number;
		public static var timer_GrandChildToEnd:Number;
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
		
		public var playIntro:Intro;
		
		public function LoadXmlData() 
		{
			init();
			playIntro = new Intro();
		}
		
		public function init():void
		{
			
			// speed
			VB = 0;
			CT_VB = 0.6;
			
			// scurve
			COEFF_D = 1.6;
			COEFF_D_CHILD = 2;
			COEFF_D_GRANDCHILD = 2.4;
			
			D_MAX = 1800; 
			S_MIN = -1.2;
			S_MAX = 2;
			
			// timers
			timer_ToChild = 60;
			timer_FatherToDeath = 80;
			timer_ChildToGrandChild = 80;
			timer_GrandChildToEnd = 80;
			
			// debug
			DEBUG = false;
			GODMODE = false;
			LD = true;
		
			// citation
			CITATION = "... comme il se souviennent certainement des leurs; et eux comme moi, à tort ou à raison, sommes ce qu'ils ont fait de nous ..."; 
			
			//volume
			VOLUME = 1;
			
			//transmition timer
			TRANS_TIMER = 14;
			
			// HUD
			HUD = true;
	
		}
	}

}