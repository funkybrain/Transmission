﻿package rooms
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
	
	public class Level extends LevelLoader
	{
		/**
		 * Level XML.
		 */
		[Embed(source = '../../level/Level_Romain.oel', mimeType = 'application/octet-stream')] private static const LEVEL:Class;
		[Embed(source = '../../level/Level_Test_Manu.oel', mimeType = 'application/octet-stream')] private static const LEVEL_TEST:Class;
		
		
		/**
		 * Size of the level (so it knows where to keep the player + camera in).
		 */
		public var width:uint;
		public var height:uint;
		
		// List<Animation> to store background animations
		private var _animationList:Vector.<Animation> = new Vector.<Animation>();
		
		// class variable
		private var _player:Player;
		
		/**
		 * Constructor.
		 */
		public function Level()
		{
			var loadLevel:Class;
			
			if (LoadXmlData.LD) 
			{
				loadLevel = LEVEL;
			} else {
				loadLevel = LEVEL_TEST;
			}
			
			super(loadLevel);

			width = level.width;
			height = level.height;
		}
		
		public function addObjectsToWorld(world:World):void
		{
			// add paths to world
			world.add(new PathRed(level));
			world.add(new PathBlue(level));
			world.add(new PathGreen(level));
			
			// add background image
			for each (var b:XML in level.background[0].image_fond)
			{
				world.add (new Background(b.@x, b.@y));
				
			}
						
		
		}
		
		public function addBackgroundAnimationsToWorld(world:World):Vector.<Animation>
		{
			//add animations to world
			for each (var q:XML in level.animations.anim_man)
			{
				// add new animation to Vector and Level
				var index_one:int = _animationList.push(new Animation(q.@x, q.@y, "man", 1));
				world.add(_animationList[index_one-1]);
			}

			for each (var r:XML in level.animations.anim_rouage)
			{
				// add new animation to Vector and Level
				var index_two:int = _animationList.push(new Animation(r.@x, r.@y, "rouage", 1));
				world.add(_animationList[index_two-1]);
			}
			
			for each (var o:XML in level.animations.anim_prison)
			{
				// add new animation to Vector and Level
				var index_three:int = _animationList.push(new Animation(o.@x, o.@y, "prison", 0));
				world.add(_animationList[index_three-1]);
			}
			
			for each (var s:XML in level.animations.anim_crash)
			{
				// add new animation to Vector and Level
				var index_four:int = _animationList.push(new Animation(s.@x, s.@y, "crash", 0));
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