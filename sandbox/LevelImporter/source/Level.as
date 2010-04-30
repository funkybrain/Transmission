package source 
{
	import punk.core.World;
	/**
	 * ...
	 * @author manu
	 */
	public class Level extends World
	{
		//[Embed(source = 'levels/level_grid.oel', mimeType = "application/octet-stream")]
		//	private var LEVEL_1:Class;	
			
		public var xmltest:LevelLoader;	

		public function Level() 
		{
				trace("Level created!");
				xmltest = new LevelLoader;
		}
		
		/*public function loadLevel(file:Class):void
		{
		// load the level xml
		var bytes:ByteArray = new file;
		level = new XML(bytes.readUTFBytes(bytes.length));

		// load level information
		//title = level.@title;
		width = level.width / 16;
		height = level.height / 16;

		// load walls
		for each (var o:XML in level.objects.wall)
			add(new Wall(o.@x, o.@y, o.@width, o.@height));

		// load springs
		for each (o in level.objects.spring)
			add(new Spring(o.@x, o.@y, -o.@speed));

		// load spikes
		for each (o in level.objects.spikes)
			add(new Spikes(o.@x, o.@y, o.@width, o.@height));
			
		// load gems
		for each (o in level.objects.gem)
			add(new Gem(o.@x, o.@y));
		}*/
			
	}

}