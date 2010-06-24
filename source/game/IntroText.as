package game 
{
	import net.flashpunk.Entity;
	import net.flashpunk.graphics.Text
	import net.flashpunk.FP;
	import net.flashpunk.tweens.misc.Alarm;
	import net.flashpunk.tweens.misc.VarTween;
	import game.StringUtils;
	import net.flashpunk.utils.Ease;
	
	public class IntroText extends Entity
	{
			
		[Embed(source='../../assets/fonts/ARIAL.TTF', fontFamily = 'quote')]
		private static const FONT:Class;
		
		private var _firstWords:Text;
		private var autoKill:Alarm;
		private var fadetext:VarTween;
		
		//public var introFadeOut:Curtain;
		
		public function IntroText() 
		{
			x = 0;
			y = 0;
		
			_firstWords = new Text("Je me souviens de mes parents...", 130, 200, 800, 50);	
			_firstWords.font = "quote";
			_firstWords.size = 36;
			_firstWords.color = 0xFFFFFF;
			
			graphic = _firstWords;
			
			layer = 0;
			
			init();
		}
		
		public function init():void 
		{
			fadetext = new VarTween(null, 2);
			fadetext.tween(_firstWords, "alpha", 0, 15, Ease.circIn);
			autoKill = new Alarm(15, onAutoKill, 2);
			addTween(fadetext);
			fadetext.start();
			addTween(autoKill, true);
		}
		
		private function onAutoKill():void
		{
			FP.world.remove(this);
		}
		
	}

}