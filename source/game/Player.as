﻿package game 
{
	import adobe.utils.CustomActions;
	import flash.display.Sprite;
	import flash.geom.Point;
	import net.flashpunk.graphics.Emitter;
	import net.flashpunk.graphics.Graphiclist;
	import net.flashpunk.graphics.Image;
	import net.flashpunk.graphics.ParticleType;
	import net.flashpunk.graphics.Spritemap;
	import net.flashpunk.tweens.misc.*;
	import net.flashpunk.tweens.motion.LinearMotion;
	import net.flashpunk.tweens.sound.SfxFader;
	import net.flashpunk.utils.Ease;
	import net.flashpunk.utils.Input;
	import net.flashpunk.utils.Key;
	import game.LoadXmlData;

	
	import net.flashpunk.*;
	
	public class Player extends Moveable
	{
		/**
		 * Player graphic.
		 */
		[Embed(source = '../../assets/spritesheetAvatar.png')] private const PLAYER:Class;
		public var father:Spritemap = new Spritemap(PLAYER, 30, 30);
		
		[Embed(source = '../../assets/spritesheetAvatarFils.png')] private const CHILD:Class;
		public var child:Spritemap = new Spritemap(CHILD, 30, 30);
		
		[Embed(source = '../../assets/spriteSheetGrandChild.png')] private const GRAND_CHILD:Class;
		public var grandChild:Spritemap = new Spritemap(GRAND_CHILD, 30, 30);
		
		/**
		 * Tweeners.
		 */
		//public const SCALE:LinearMotion = new LinearMotion;
		//public const ROTATE:NumTween = new NumTween;
		public const fadeOut:VarTween = new VarTween;
		
		/**
		 * Alarms.
		 */
		public var timeToChild:Alarm;
		public var timeFatherToChild:Alarm;
		public var timeFatherToDeath:Alarm;
		public var timeToGrandChild:Alarm;
		public var timeGrandChildToEnd:Alarm;
		public var timers:Vector.<Alarm> = new Vector.<Alarm>(); // store all alarms
		
	
		/**
		 * Game (transmission) specific variables.
		 */
		//private const COEFF_D:Number = 2; // used in S-curve calculation		
		//public const VB:Number = 0.3; // base speed of father
		//public const CT_VB:Number = 0.2; // Ctvb : coeff de transmission de la vitesse de base father -> child
		
		public var COEFF_D:Number; // used in S-curve calculation		
		public var VB:Number; // base speed of father
		public var CT_VB:Number; // Ctvb : coeff de transmission de la vitesse de base father -> child
		public var D_MAX:Number; // max distance used in mapping for s-curve data
		public var S_MIN:Number; // s-cruve mini abcisse
		public var S_MAX:Number; // s-cruve max abcisse
		
		public var transmitModel:uint;
		public var transmitIndexX:Number;
		public var transmitIndexY:Number;
		public var transmitIndexZ:Number;
		public var Dxtotale:Number;
					
		/**
		 * Movement properties
		 */
		public var previousPos:Point; // previous player position
		public var pathIndex:uint; // index to target the required path when calling an array
		public var distance:Number = 0; // frame by frame distance
		public var vbArray:Array; // initial speed array
				
		public var moveHistory:Vector.<Point> = new Vector.<Point>(); // List<Point> to store player move history
		private var _moveIndex:uint; // current index of List<Point>
		public var pathHistory:Array = new Array(); // store the path index along with move history
		private var _pathIndex:uint; // current index of pathHistory
		
		public var animatedTile:PathTile; // used to place animated tiles
		public var pathTileList:Vector.<PathTile> = new Vector.<PathTile>(); // List<PathTile> to store animated tiles
		public var row:int, col:int; 
		
		public var typeVitesse:String; // debug property
		private var _type3:Boolean = false; // flag to ensure once child is going at type 3 vel, it stays there
		// store the greater of pathMaxVel and PathChildSpeed
		private var _maxPathSpeed:Array = new Array();

		
		/**
		 * Special speed properties for child
		 */
		public var pathChildSpeed:Array = new Array();
		 
		/**
		 * Save father data upon transmission
		 */
		public var fatherStoredDistances:Array = new Array();
		public var fatherStoredVelocities:Array = new Array();
		public var childStoredDistances:Array = new Array();
		public var childStoredVelocities:Array = new Array(); 

		/**
		 * Player state.
		 */
		public var state:String = "father";
		public var deathImminent:Boolean = false;
		
		/**
		 * Animation properties.
		 */
		public var frames:Array;
		
		/**
		 * define hitbox origin.
		 */		
		private var offsetOriginX:int;
		private var offsetOriginY:int;
		
		/**
		 * Sound properties
		 */
		public var sound:SoundManager; // obj ref to handle all sounds
		private var _pathSwitchLocation:Point = new Point(); // location where path changed
		private var _pathPreviousIndex:uint; // path index of previous frame
		private var _pathSwitchTable:Array = new Array(); // store path index when changed
		private var _pathSwitched:Boolean = false;
		private var _pathSwitchClonedPosition:Boolean = false;
		private var fromSound:SfxFader;
		private var toSound:SfxFader;
						
		
		/**
		 * Particle emitter.
		 */
		
		/**
		 * CONSTRUCTOR
		 */
		public function Player(_x:int=0, _y:int=0, _vb:Array=null) 
		{
			this.x = _x;
			this.y = _y;
			
			// set position vector as entity's coordinates
			position.x = x;
			position.y = y;
			
			// set initial player position as first previousPos
			previousPos = position.clone();
			
			// set the Entity's graphic property to a Spritemap object
			graphic = father;
			frames = new Array( 0, 1, 2, 3 );
			father.add("walk", frames, 5, true);
			child.add("walk", frames, 5, true);
			grandChild.add("walk", frames, 5, true);
			
			// NOTE: if you're going down the route of fixed framrate, use 
			// avatar.add("walk", frames, 5*(1/FP.frameRate), true);
			
			//hitbox based on image size
			// set hitbox origin at c. 2/5th right and 2/3rd down from entity origin
			offsetOriginX = -1.5*(father.width/5);
			offsetOriginY = -1.7*(father.height/3);
			// set hitbox width and height
			var boxWidth:int = father.width / 3;
			var boxHeight:int = father.height / 4;					
			setHitbox(boxWidth, boxHeight, offsetOriginX, offsetOriginY);
			
			/*
			TODO center the origin of the player
			avatar.originX = avatar.width / 2;
			avatar.originY = avatar.height / 2;
			avatar.x = -avatar.originX;
			avatar.y = -avatar.originY;
			avatar.smooth = true;
			*/
			
			// define payer movement keys
			Input.define("R", Key.RIGHT);
			Input.define("L", Key.LEFT);
			Input.define("U", Key.UP);
			Input.define("D", Key.DOWN);
			
			// Initialize
			// distance (0) on each path type
			for (var i:int = 0; i < 3; i++) 
			{
				pathDistance[i] = 0;
			}
			
			// initialize variables from gamedata.xml file
			COEFF_D = LoadXmlData.COEFF_D; // used in S-curve calculation		
			VB = LoadXmlData.VB; // base speed of father
			CT_VB = LoadXmlData.CT_VB; // Ctvb : coeff de transmission de la vitesse de base father -> child
			D_MAX = LoadXmlData.D_MAX;
			S_MIN = LoadXmlData.S_MIN;
			S_MAX = LoadXmlData.S_MAX;
			
			// and basic speed vb on each path (pathBaseSpeed is an array)
			vbArray = new Array(VB, VB, VB);
			if (_vb == null	) 
			{
				pathBaseSpeed = vbArray; //NOTE may have to concat() to make a true copy
			} 
			
			// kick-off soundtrack as player comes into existence
			sound = new SoundManager();
			
			// to avoid crash in case child appears before player has moved
			moveHistory.push(new Point());
			
			
		}
		
		private function printDebugInfo(from:uint):void
		{
			var debutext:String;
			switch (from)
				{
				case 1:
					debutext = "crashed when player first added to world";
					break;
				case 2:
					debutext = "crashed in player update, at beginning of loop";
					break;
				case 3:
					debutext = "crashed in player update, after the move";
					break;
				}
			trace(debutext);
			
			trace("state: " + state);
			trace("x: " + x);
			trace("y: " + y);
				
		}
		
		/**
		 * play music at game start
		 */
		override public function added():void
		{
			_pathPreviousIndex = getCurrentPath(); // find path player is on to play the correct file
			// debug if =3
			if (_pathPreviousIndex == 3) 
			{
				
				printDebugInfo(1);
				
			}
			
			// start all sounds but only turn up volume on current path
			for each (var music:Sfx in sound.pathSound) 
			{
					//music.play() //player movement controls play 
					music.volume = 0;
			}
			sound.pathSound[_pathPreviousIndex].volume = 1;

			
			// intialize switch variables
			_pathSwitchTable[0] = _pathSwitchTable[1] = _pathPreviousIndex;
			_pathSwitchLocation = position.clone();
		}
		
		/**
		 * PLAYER UPDATE LOOP
		 */
		override public function update():void 
		{
			// find out what path the player is on
			pathIndex = getCurrentPath();
			//debug if =3
			if (pathIndex == 3) 
			{
				
				printDebugInfo(2);
				
			}
			
			//store current path index
			if (_pathSwitched==false) 
			{
				_pathSwitchTable[0] = pathIndex;
			}
			
			// update speed on paths based on new pathDistance
			calculateSpeed();
			
			//check if a new animated tile needs to be placed where player has walked
			var shiftX:Number, shiftY:Number; // need to locate the center of the entity		
			shiftX = x - offsetOriginX;
			shiftY = y - offsetOriginY;
			addNewTile(shiftX, shiftY, Path.TILE_GRID);
			
			// move player based on maximum speeds returned by the calculateSpeed method
			move(pathIndex);
			
			//store new path index
			_pathSwitchTable[1] = getCurrentPath();
			//debug if =3
			if (_pathSwitchTable[1] == 3) 
			{
				
				printDebugInfo(3);
				
			}
			
			//store player location if path has changed
			if (_pathSwitchTable[0]!=_pathSwitchTable[1] && _pathSwitchClonedPosition==false) 
			{
				//trace("player has changed path!");
				_pathSwitchClonedPosition = true;
				 // stop storing _pathSwitchTable[0] until 30 pixels have passed
				_pathSwitched = true;
				 // store position where path changed
				_pathSwitchLocation = position.clone();
				//trace("pathSwitchTable: " + _pathSwitchTable);
				
			}
			
			
			// if distance since last path switch is grater than 30 pixel, test for real switch
			if (Point.distance(position,_pathSwitchLocation) > 30 && _pathSwitched == true) 
			{
				//trace("distance > 30px");
				if (_pathSwitchTable[0]!=_pathSwitchTable[1]) // paths are still different after 30px
				{
					//trace("permanent path change");
					// play music based on current path and latest path change
					playPathMusic();
				}
				_pathSwitched = false;
				_pathSwitchClonedPosition = false;
				//trace("dist: " + Point.distance(position, _pathSwitchLocation));				
			}

			
			// calculate distance traveled since last frame and add to that path total
			distance = Point.distance(position, previousPos);
			pathDistance[pathIndex] += distance;
			
			// calculate distance traveled on all paths
			getTotalDistanceTravelled();
			
			// calculate path distance ratios
			getPathRatios();
			
			// play sprite animation
			animation();
			
			//store current position as next previous position
			previousPos = position.clone();
			
			//store current player position in move history 
			if (velocity.x!=0 || velocity.y!=0) 
			{
				_moveIndex = moveHistory.push(previousPos);
				_pathIndex = pathHistory.push(pathIndex);
				
				//pop oldest move history from List to keep only the last 60 moves
				if (_moveIndex==60) 
				{
					moveHistory.shift();
					pathHistory.shift();
				}
			
			}
			


		}
		
		
		/**
		 * Play music track based on path
		 */
		public function playPathMusic():void
		{
			//compare the two stores path indexes (seperated by 30 pixels distance)
			//if they are different, then player has really changed path
			//as opposed to crossed an intersection
			if (_pathSwitchTable[1]!=_pathSwitchTable[0]) 
			{

				var idFrom:int = _pathSwitchTable[0];
				var idTo:int = _pathSwitchTable[1];
				fromSound = sound.pathFader[idFrom];
				toSound = sound.pathFader[idTo];
				
				fromSound.fadeTo(0, 4, Ease.expoOut);
				toSound.fadeTo(1, 4, Ease.sineIn);
				fromSound.start();
				toSound.start();
				
/*				trace("start xfade");
				trace("playing sound: " + idFrom);
				trace("moving to sound: " + idTo);
*/				
			}

		}
		 
		/**
		 * animated tile placement method
		 */
		public function addNewTile(_x:int, _y:int, _step:int ):void
		{
			// convert x,y into row, col
			var tileExists:Boolean = false;
			
			col = Math.floor(_x / _step);
			row = Math.floor(_y / _step);
			
			// loop through vector to see if a path of index (row,col) already exists
			for each (var value:PathTile in pathTileList)
			{
				if (value.row==row && value.col == col) 
				{
					tileExists = true;
					break;
				}				
			}
			//trace(tileExists);
			if (tileExists==false) 
			{
				// add new animated tile to Vector and Level
				var index:int = pathTileList.push(new PathTile(col, row, _step, pathIndex));
				//trace("path index: " + pathIndex);
				FP.world.add(pathTileList[index-1]);
			}
		}
		
		/**
		 * Calculate total distance travelled, all paths included
		 */
		private function getTotalDistanceTravelled():void
		{
			var total:Number = 0;
			
			for (var i:int = 0; i < 3; i++) 
			{
				total += pathDistance[i];
			}
			
			totaldistance = total;
		}
		
		/**
		 * Calculate path distance ratios
		 */
		private function getPathRatios():void
		{
			for (var i:int = 0; i < 3; i++) 
			{
				pathDistToTotalRatio[i] = pathDistance[i] / totaldistance;
			}
				//trace(distance);
				//trace(pathDistance[pathIndex]);
		}
		
		/**
		 * Moves the player based on input
		 */
		private function move(pathType:uint):void
		{
			// evaluate input
			velocity.x = 0;
			velocity.y = 0;			
			var sign:int, e:Entity;
			var pathMaxSpeed:Number;
			
			//BUG the erratic bug may come from the fact that at high speeds I don't pixel-check move
			
			// check if god mode is on to set unique value for fast playthrough
			if (LoadXmlData.GODMODE==true) 
			{ // use god speed
				pathMaxSpeed = 4;	
			} else // use normal velocity calculations
			{
				pathMaxSpeed = pathInstantVel[pathType];
			}
			
			
			if (Input.check("R"))
			{
				if ((e = collideTypes(pathCollideType, x + pathMaxSpeed, y)))
				{
					velocity.x = pathMaxSpeed * (FP.frameRate * FP.elapsed);
				} else 
				{
					velocity.x = 0;
				}
				
			}
						
			if (Input.check("L"))
			{
				if ((e = collideTypes(pathCollideType, x - pathMaxSpeed, y)))
				{
					//velocity.x = -pathMaxVel[pathType];
					velocity.x = -VB* (FP.frameRate * FP.elapsed); // make going backward a pain in the ass!
				} else 
				{
					velocity.x = 0;
				}	
				
				
			}
			
			if (Input.check("U"))
			{
				if ((e = collideTypes(pathCollideType, x, y - pathMaxSpeed)))
				{
					velocity.y = -pathMaxSpeed * (FP.frameRate * FP.elapsed);
				} else 
				{
					velocity.y = 0;
				}
				
				
			}
			
			if (Input.check("D"))
			{
				if ((e = collideTypes(pathCollideType, x, y + pathMaxSpeed)))
				{
					velocity.y = +pathMaxSpeed * (FP.frameRate * FP.elapsed);
				} else 
				{
					velocity.y = 0;
				}	
				

			}
			
			// add position to velocity vector
			
			position.x = (position.add(velocity)).x;
			position.y = (position.add(velocity)).y;
			
			// set new player x,y
			x = position.x;
			y = position.y;
			
			
		}
		// end acceleration()
		
		
		
		/**
		 * Calculate pllayer velocity based on path and state (father, child, grandchild)
		 */
		private function calculateSpeed():void
		{			
			var coeff_type3:Number = 0.25;
			var DyDz:Number;
			
			// work out the combined distance of the two paths where previous avatar was slowest
			if (state=="child" || state=="grandChild") 
			{
				DyDz = pathDistance[transmitIndexY] + pathDistance[transmitIndexZ];
			}

			// store the fastest velocity out of the three paths	
			pathFastest = Math.max(pathMaxVel[0], pathMaxVel[1], pathMaxVel[2]);

			// start loop
			for (var i:int = 0; i < 3; i++) 
			{
				// use s-curve calculations to figure out max velocity							
				// first map distance on path to s-curve significant numbers
				var mapped:Number = FP.scale(pathDistance[i], 0, D_MAX, S_MIN, S_MAX);
				pathMaxVel[i] = pathBaseSpeed[i] + COEFF_D * (1 / (1 + Math.exp( -mapped)));
				
				// find out the greater of pathMaxVel and PathChildSpeed
				_maxPathSpeed[i] = Math.max(pathMaxVel[i], pathChildSpeed[i]);
				
				// if player is father or followed by robot child (before transmission)
				if (state=="father" || state=="childAlive") 
				{
					pathInstantVel[i] = pathMaxVel[i];
					typeVitesse = "normale (pere)";
				}
				
				if (state=="child" || state=="grandChild") 
				{
					
					// check if type 3 comes into effect
					if (DyDz > (0.25 * Dxtotale))
					{
						/*									
						trace("Dz: " + pathDistance[transmitIndexZ].toFixed(2));
						trace("Dy: " + pathDistance[transmitIndexY].toFixed(2));
						trace("Dx: " + Dxtotale.toFixed(2));
						trace("DyDz: " + DyDz.toFixed(2));
						trace("0.25*Dx: " + (coeff_type3 * Dxtotale).toFixed(2));*/
						if (!_type3) 
						{
							trace("DyDz sup à  0.25 x Dxtotale - vitesse 3");	
						}
						_type3 = true;
						
					}
			
					if (_type3) // must keep this speed till death 
					{
						pathInstantVel[i] = pathFastest;
						typeVitesse = "type 3 - constant (Vmax)";
						
					} else if (pathMaxVel[i] < pathChildSpeed[i]) 
					{
						typeVitesse = "type 1 - constant (child modele 1)";
						pathInstantVel[i] = _maxPathSpeed[i];
						
					} else
					{
						typeVitesse = "type 2 - comme pere (child modele 1)";
						pathInstantVel[i] = _maxPathSpeed[i];
					}
				}
			
			
			}

		}
		
		
		
		/**
		 * Handles animation based on current player state.
		 */
		private function animation():void
		{
			// switch to the correct Spritemap to play the animation
			var who:Spritemap;
			
			switch (state) 
			{
				case "father":
					who = father;
					break;
				case "childAlive":
					who = father;
					break;	
				case "child":
					who = child;
					break;
				case "grandChild":
					who = grandChild;
					break;	
			}
			
			if (velocity.x != 0 || velocity.y != 0)
			{
				who.play("walk");
			} else {
				who.setFrame(0);
			}
			
		}	
	}
}