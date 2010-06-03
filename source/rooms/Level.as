package rooms
{
	//import game.Particles;
	
	import game.Debug;
	import game.LoadXmlData;
	import game.PathRed;
	import game.PathBlue;
	import game.PathGreen;
	import game.PathTile;
	import game.Player;
	import game.Robot;
	import game.SoundManager;
	import game.Background;
	import game.Animation;
	import game.Shutter;
	import net.flashpunk.Entity;
	import net.flashpunk.FP;
	import net.flashpunk.graphics.Anim;
	import net.flashpunk.graphics.Text;
	import net.flashpunk.tweens.misc.Alarm;
	import net.flashpunk.tweens.misc.NumTween;
	import net.flashpunk.utils.Ease;
	import net.flashpunk.World;
	import flash.xml.*;
	
	public class Level extends LevelLoader
	{
		/**
		 * Level XML.
		 */
		[Embed(source = '../../level/Level_Romain.oel', mimeType = 'application/octet-stream')]
		private static const LEVEL:Class;
		
		[Embed(source = '../../level/Level_Romain_2.oel', mimeType = 'application/octet-stream')]
		private static const LEVEL_2:Class;
		
		[Embed(source = '../../level/Level_Test_Manu.oel', mimeType = 'application/octet-stream')]
		private static const LEVEL_TEST:Class;
		
		[Embed(source = '../../level/Level_Test_Manu_2.oel', mimeType = 'application/octet-stream')]
		private static const LEVEL_TEST_2:Class;
		
		
		/**
		 * Size of the level (so it knows where to keep the player + camera in).
		 */
		public var width:uint;
		public var height:uint;
		
		// List<Animation> to store background animations
		private var _animationList:Vector.<Animation> = new Vector.<Animation>();
		
		// class variable
		private var _player:Player;
		private var _offset:int;
		
		
		/**
		 * 
		 * @param	number	level to load
		 * @param	offset	sets the x offset of all objects for all levels above 1
		 */
		public function Level(number:uint, offset:int)
		{
			this._offset = offset;
			
			var loadLevel:Class;
		
			if (!LoadXmlData.LD) 
			{
				switch (number) 
				{
					case 1:
						loadLevel = LEVEL_TEST;
						break;
					case 2:
						loadLevel = LEVEL_TEST_2;
						break;
					default:
						loadLevel = LEVEL_TEST;
						break;
				}
				
			} else {
				switch (number) 
				{
					case 1:
						loadLevel = LEVEL;
						break;
					case 2:
						loadLevel = LEVEL_2
						break;
					default:
						loadLevel = LEVEL_TEST;
						break;
				}
			}
			
			trace("loading level: " + loadLevel);
			super(loadLevel);

			width = level.width;
			height = level.height;
			trace(level.width);
			trace(level.height);
			
		}
		
		public function addObjectsToWorld(world:World):void
		{
			// add paths to world
			world.add(new PathRed(level, _offset));
			world.add(new PathBlue(level, _offset));
			world.add(new PathGreen(level, _offset));
			
			// add background image
			
			if (level.hasOwnProperty("background")) 
			{
				for each (var b:XML in level.background[0].image_fond)
				{
					var fix:int = int(b.@x) + _offset;
					
					world.add (new Background(fix, b.@y));
					
					trace("added background at: " + fix);
				}	

			}
		}
		
		public function addBackgroundAnimationsToWorld(world:World):Vector.<Animation>
		{
			//add animations to world
			for each (var q:XML in level.animations.anim_man)
			{
				// add new animation to Vector and Level
				var _x1:int = int(q.@x) + _offset;
				var index_one:int = _animationList.push(new Animation(_x1, q.@y, "man", 1));
				world.add(_animationList[index_one-1]);
				trace("man x: " + _animationList[index_one-1].x);
			}

			for each (var r:XML in level.animations.anim_rouage)
			{
				// add new animation to Vector and Level
				var _x2:int = int(r.@x) + _offset;
				var index_two:int = _animationList.push(new Animation(_x2, r.@y, "rouage", 1));
				world.add(_animationList[index_two - 1]);
				trace("rouage x: " + _animationList[index_two-1].x);
			}
			
			for each (var o:XML in level.animations.anim_prison)
			{
				// add new animation to Vector and Level
				var _x3:int = int(o.@x) + _offset;
				var index_three:int = _animationList.push(new Animation(_x3, o.@y, "prison", 0));
				world.add(_animationList[index_three-1]);
			}
			
			for each (var s:XML in level.animations.anim_crash)
			{
				// add new animation to Vector and Level
				var _x4:int = int(s.@x) + _offset;
				var index_four:int = _animationList.push(new Animation(_x4, s.@y, "crash", 0));
				world.add(_animationList[index_four-1]);
			}
			
			return _animationList;
		}
		
		public function addPlayerToWorld(world:World):Player
		{
			//add player to world
			for each (var p:XML in level.player[0].player) //this is redundant, only one player
			{
				_player = new Player(p.@x, p.@y);
				world.add(_player);
			}
			
			return _player;
		}
	}
				
}