package game 
{
	import adobe.utils.ProductManager;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import net.flashpunk.graphics.Text;
	import net.flashpunk.Entity;
	import net.flashpunk.FP;
	import net.flashpunk.utils.Draw;
	
	public class GameOverlay extends Entity
	{
		[Embed(source='../../assets/fonts/ARIAL.TTF', fontFamily = 'over')]
		private static const FNT_ARIAL:Class;

		// avatar timer displayed in lower right corner
		public var displayTimer:Text;
		
		// progress bar diplayed at screen bottom
		/*private var _lineTopLeft:Point = new Point(60, 445);
		private var _lineBotLeft:Point = new Point(60, 475)
		private var _lineTopRight:Point = new Point(740, 445);
		private var _lineBotRight:Point = new Point(740, 475);

		private var _rectOrigin:Point = new Point(60, 450);
		private var _rectWidth:int = 0;
		private var _rectHeight:int = 20;		
		
		private var _cursorTop:Point = new Point();
		private var _cursorBot:Point = new Point();
		
		public var maxLength:int;*/
		
		// plus fin
		private var _lineTopLeft:Point = new Point(15, 445);
		private var _lineBotLeft:Point = new Point(15, 470)
		private var _lineTopRight:Point = new Point(730, 445);
		private var _lineBotRight:Point = new Point(730, 470);

		private var _rectOrigin:Point = new Point(15, 450);
		private var _rectWidth:int = 0;
		private var _rectHeight:int = 15;		
		
		private var _cursorTop:Point = new Point();
		private var _cursorBot:Point = new Point();
		
		public var maxLength:int;
		
		public function GameOverlay() 
		{
						
			this.x = FP.camera.x;
			this.y = 0;
			

			
			displayTimer = new Text("", 0, 0, 50, 50);
			displayTimer.font = "over";
			displayTimer.color = 0xDFFEDC;
			displayTimer.size = 36;
			

			graphic = displayTimer;
			
			layer = Layers.OVERLAY;
			
			maxLength = _lineTopRight.x - _lineTopLeft.x;
		}
		
		public function updateTimer(time:Number):void
		{
			displayTimer.text = time.toString();
			x = FP.camera.x + 745;
			y = FP.camera.y + 435;
			//trace("timer: " + timer.text);
		}
		
		public function drawProgressBar(length:Number):void
		{
			_rectWidth = length;
			_cursorTop.x = _lineTopLeft.x + length;
			_cursorTop.y = _lineTopLeft.y;
			_cursorBot.x = _lineBotLeft.x + length;
			_cursorBot.y = _lineBotLeft.y;
		}
		
		override public function render():void 
		{
			super.render();
			Draw.rect(FP.camera.x + _rectOrigin.x, _rectOrigin.y, _rectWidth, _rectHeight, 0xDFFEDC, 0.9);
			
			Draw.linePlus(FP.camera.x + _lineTopLeft.x, _lineTopLeft.y, FP.camera.x + _lineTopRight.x, _lineTopRight.y, 0xDFFEDC, 1, 2);
			Draw.linePlus(FP.camera.x + _lineBotLeft.x, _lineBotLeft.y, FP.camera.x + _lineBotRight.x, _lineBotRight.y, 0xDFFEDC, 1, 2);
			Draw.linePlus(FP.camera.x + _lineTopLeft.x, _lineTopLeft.y, FP.camera.x + _lineBotLeft.x, _lineBotLeft.y, 0xDFFEDC, 1, 2);
			Draw.linePlus(FP.camera.x + _lineTopRight.x, _lineTopRight.y, FP.camera.x + _lineBotRight.x, _lineBotRight.y, 0xDFFEDC, 1, 2);
			Draw.rect(FP.camera.x + _lineTopLeft.x, _lineTopLeft.y, (_lineTopRight.x - _lineTopLeft.x), (_lineBotLeft.y - _lineTopLeft.y), 0xFFFFFF, 0.5);
			
			
			Draw.linePlus(FP.camera.x + _cursorTop.x, _cursorTop.y, FP.camera.x + _cursorBot.x, _cursorBot.y, 0x2C45AA, 1, 5);
			

		}
		
		
	}

}