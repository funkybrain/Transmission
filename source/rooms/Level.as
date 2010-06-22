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
		private var _backgroundList:Vector.<Background> = new Vector.<Background>();
		
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
			
			//trace("loading level: " + loadLevel);
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
			
		}
		
		public function addBackgroundsToWorld(world:World):Vector.<Background>
		{
			// add background image
			if (level.hasOwnProperty("background")) 
			{
				for each (var ba:XML in level.background[0].image_fond)
				{
					var _xba:int = int(ba.@x) + _offset;
					var ba_index:int = _backgroundList.push(new Background(_xba, ba.@y, 0));
					world.add (_backgroundList[ba_index-1]);
					
					//trace("added background at: " + _xba);
				}
				
				for each (var bb:XML in level.background[0].image_fond_1)
				{
					var _xbb:int = int(bb.@x) + _offset;
					var bb_index:int = _backgroundList.push(new Background(_xbb, bb.@y, 1));
					world.add (_backgroundList[bb_index-1]);
					
					//trace("added background at: " + _xbb);
				}
				
				for each (var bc:XML in level.background[0].image_fond_2)
				{
					var _xbc:int = int(bc.@x) + _offset;
					var bc_index:int = _backgroundList.push(new Background(_xbc, bc.@y, 2));
					world.add (_backgroundList[bc_index-1]);
					
					//trace("added background at: " + _xbc);
				}
				
				for each (var bd:XML in level.background[0].image_fond_3)
				{
					var _xbd:int = int(bd.@x) + _offset;
					var bd_index:int = _backgroundList.push(new Background(_xbd, bd.@y, 3));
					world.add (_backgroundList[bd_index-1]);
					
					//trace("added background at: " + _xbd);
				}
				
				for each (var be:XML in level.background[0].image_fond_4)
				{
					var _xbe:int = int(be.@x) + _offset;
					var be_index:int = _backgroundList.push(new Background(_xbe, be.@y, 4));
					world.add (_backgroundList[be_index-1]);
					
					//trace("added background at: " + _xbe);
				}
				
			}
			return _backgroundList;
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
				//trace("man x: " + _animationList[index_one-1].x);
			}

			for each (var r:XML in level.animations.anim_rouage)
			{
				// add new animation to Vector and Level
				var _x2:int = int(r.@x) + _offset;
				var index_two:int = _animationList.push(new Animation(_x2, r.@y, "rouage", 1));
				world.add(_animationList[index_two - 1]);
				//trace("rouage x: " + _animationList[index_two-1].x);
			}
			
			for each (var o:XML in level.animations.anim_prison)
			{
				// add new animation to Vector and Level
				var _x3:int = int(o.@x) + _offset;
				var index_three:int = _animationList.push(new Animation(_x3, o.@y, "prison", 0));
				world.add(_animationList[index_three-1]);
				trace("prison x: " + _animationList[index_three-1].x);
			}
			
			for each (var s:XML in level.animations.anim_crash)
			{
				// add new animation to Vector and Level
				var _x4:int = int(s.@x) + _offset;
				var index_four:int = _animationList.push(new Animation(_x4, s.@y, "crash", 0));
				world.add(_animationList[index_four - 1]);
				trace("crash x: " + _animationList[index_four - 1].x);
				trace("crash trigger x: " +  _animationList[index_four - 1].triggerDistance);
				trace("anim type: " +  _animationList[index_four - 1].animType);
			}
			
			for each (var w:XML in level.animations.anim_serveuse)
			{
				// add new animation to Vector and Level
				var _x5:int = int(w.@x) + _offset;
				var index_five:int = _animationList.push(new Animation(_x5, w.@y, "serveuse", 0));
				world.add(_animationList[index_five - 1]);
				trace("serveuse x: " + _animationList[index_five-1].x);
			}
			
			for each (var k:XML in level.animations.anim_junky)
			{
				// add new animation to Vector and Level
				var _x6:int = int(k.@x) + _offset;
				var index_six:int = _animationList.push(new Animation(_x6, k.@y, "junky", 0));
				world.add(_animationList[index_six - 1]);
				trace("junky x: " + _animationList[index_six-1].x);
			}
			
			for each (var t:XML in level.animations.anim_fatherchild)
			{
				// add new animation to Vector and Level
				var _x7:int = int(t.@x) + _offset;
				var index_seven:int = _animationList.push(new Animation(_x7, t.@y, "fatherchild", 1));
				world.add(_animationList[index_seven - 1]);
				trace("fatherchild x: " + _animationList[index_seven-1].x);
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
		
		public function getTriggerPosition():int
		{
			if (level.waypoints.hasOwnProperty("trigger")) 
			{
				var _x5:int = int(level.waypoints[0].trigger.@x) + _offset;
				return _x5;
			} else return 50000;
		}
	}
				
}