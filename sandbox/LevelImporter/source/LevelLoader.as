package source 
{
	/**
	 * ...
	 * @author manu
	 */
	
	import flash.net.URLLoader
	import flash.net.URLRequest
	import flash.xml.*
	import flash.errors.*
	import flash.events.*
	
	public class LevelLoader
	{
		
		public var mainXML:XML;
		public var loader:URLLoader = new URLLoader();
		public var url:XMLList;
		
		public function LevelLoader() 
		{
			loader.addEventListener(Event.COMPLETE, onComplete);
			loader.load(new URLRequest("levels/test.xml"));
			
		}
		
		public function onComplete(evt:Event):void
		{
			mainXML = new XML(loader.data)
			trace("xml loaded, start parsing using E4X syntax");
			trace(mainXML.channel.title.text());
			trace(mainXML.channel.title);
			
			url = mainXML..item.(@id=="003").resource.@url;
			trace(url);
			trace(mainXML..item.(@id=="003").channel);

			
		}
		
		
		
	}

}