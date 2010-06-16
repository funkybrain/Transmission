package game 
{
	/**
	 * ...
	 * @author manu
	 */
	public class Utils
	{
		
		public function Utils() 
		{
			
		}
		
		public static function toARGB(rgb:uint, newAlpha:uint):uint
		{
			var argb:uint = 0;
			argb = (rgb);
			argb += (newAlpha<<24);
			return argb;
		}

		public static function toRGB(argb:uint):uint
		{
			var rgb:uint = 0;
			argb = (argb & 0xFFFFFF);
			return rgb;
		}
		
		public static function toA(argb:uint):uint
		{
			var alpha:uint = 0;
			alpha = (argb>>24)&0xFF;
			return alpha;
		}
		
		

		
	}

}