package game 
{
	import adobe.utils.CustomActions;
	import flash.display.GradientType;
	import flash.display.Sprite;
	import flash.geom.Point;
	import net.flashpunk.graphics.Emitter;
	import net.flashpunk.graphics.Graphiclist;
	import net.flashpunk.graphics.Image;
	import net.flashpunk.graphics.ParticleType;
	import net.flashpunk.graphics.Spritemap;
	import net.flashpunk.tweens.misc.*;
	import net.flashpunk.tweens.motion.LinearMotion;
	import net.flashpunk.tweens.sound.Fader;
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
		[Embed(source = '../../assets/spritesheetFather.png')] private const PLAYER:Class;
		public var father:Spritemap = new Spritemap(PLAYER, 30, 30);
		
		[Embed(source = '../../assets/spritesheetChild.png')] private const CHILD:Class;
		public var child:Spritemap = new Spritemap(CHILD, 30, 30);
		
		[Embed(source = '../../assets/spriteSheetGrandChild.png')] private const GRAND_CHILD:Class;
		public var grandChild:Spritemap = new Spritemap(GRAND_CHILD, 30, 30);
		
		[Embed(source = '../../assets/spriteSheetChildAlive.png')] private const CHILD_ALIVE:Class;
		public var childAlive:Spritemap = new Spritemap(CHILD_ALIVE, 30, 30);
		
		[Embed(source = '../../assets/spriteSheetChildAppear.png')] private const CHILD_APPEAR:Class;
		public var childAppear:Spritemap = new Spritemap(CHILD_APPEAR, 30, 30, onChildAppearComplete);
		
		[Embed(source = '../../assets/spriteSheetFatherDeath.png')] private const FATHER_DEATH:Class;
		public var fatherDeath:Spritemap = new Spritemap(FATHER_DEATH, 30, 30, onFatherDeathComplete);
		
		/**
		 * Tweeners.
		 */
		public var fadeSprite:VarTween = new VarTween(); // called from game to make grandchild disappear
		private var zoom:VarTween;
		
		/**
		 * Load external game data
		 */
		private var TIMER_CHILD:Number = LoadXmlData.timer_ToChild;
		private var TIMER_FATHERTODEATH:Number = LoadXmlData.timer_FatherToDeath;
		private var TIMER_CHILDTOGRANDCHILD:Number = LoadXmlData.timer_ChildToGrandChild;
		private var TIMER_GRANDCHILDTOEND:Number = LoadXmlData.timer_GrandChildToEnd;
		
		/**
		 * Alarms.
		 */
		public var timeToChild:Alarm;
		public var timeFatherToDeath:Alarm;
		public var timeToGrandChild:Alarm;
		public var timeGrandChildToEnd:Alarm;
		public var timers:Vector.<Alarm> = new Vector.<Alarm>(); // store all alarms
		public var transmitTimer:Alarm; // plays during change of state
		
	
		/**
		 * Game (transmission) specific variables.
		 */
		//private const COEFF_D:Number = 2; // used in S-curve calculation		
		//public const VB:Number = 0.3; // base speed of father
		//public const CT_VB:Number = 0.2; // Ctvb : coeff de transmission de la vitesse de base father -> child
		
		public var COEFF_D:Number; // used in S-curve calculation		
		public var COEFF_D_CHILD:Number
		public var COEFF_D_GRANDCHILD:Number
		
		public var VB:Number; // base speed of father
		public var CT_VB:Number; // Ctvb : coeff de transmission de la vitesse de base father -> child
		public var D_MAX:Number; // max distance used in mapping for s-curve data
		public var S_MIN:Number; // s-cruve mini abcisse
		public var S_MAX:Number; // s-cruve max abcisse
		
		public var transmitModel:uint = 3; // initialize to anything but 0,1,2
		public var transmitIndexX:Number;
		public var transmitIndexY:Number;
		public var transmitIndexZ:Number;
		public var Dxtotale:Number;
					
		/**
		 * Movement properties
		 */
		public var previousPos:Point; // previous player position
		public var currentPathIndex:uint; // index to target the required path when calling an array
		public var distance:Number = 0; // frame by frame distance
		public var vbArray:Array; // initial speed array
				
		public var moveHistory:Vector.<Point> = new Vector.<Point>(); // List<Point> to store player move history
		private var _moveIndex:uint; // current index of List<Point>
		public var pathHistory:Array = new Array(); // store the path index along with move history
		private var _pathHistoryIndex:uint; // current index of pathHistory
		
		public var animatedTile:PathTile; // used to place animated tiles
		public var pathTileList:Vector.<PathTile> = new Vector.<PathTile>(); // List<PathTile> to store animated tiles
		public var row:int, col:int; 
		
		public var typeVitesse:Array = new Array(); // debug property
		public var type3:Boolean = false; // flag to ensure once child is going at type 3 vel, it stays there
		// store the greater of pathMaxVel and PathChildSpeed
		private var _maxPathSpeed:Array = new Array();

				
		// store ratio in easy to manipulate variables
		public var ratioRouge:Number; 
		public var ratioVert:Number; 
		public var ratioBleu:Number;
		private var _maxPathRatio:Number;
		private var _minPathRatio:Number;
		
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
		 * Robots
		 */
		public var robotDaughter:Robot;
		public var robotFather:Robot;
		public var robotDaughterIsAlive:Boolean = false;
		public var robotFatherIsAlive:Boolean = false;
		
		/**
		 * Animation properties.
		 */
		public var frames:Array;
		public var framesChildAppear:Array;
		public var framesChildAlive:Array;
		public var framesFatherDeath:Array;
		
		private var _daughterMinSize:Number = 0.6;
		private var _grandChildMinSize:Number = 0.6;
		
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
		 * Booleans
		 */
		public var isMoving:Boolean = false;
		public var wasMoving:Boolean = false;
		public var accouche:Boolean = false;
		public var isChildAppearing:Boolean = false;
		public var isChildAlive:Boolean = false;
		public var isFatherDying:Boolean = false;
		public var isDaughterDying:Boolean = false;
		public var isPlayerDead:Boolean = false;
		public var hasControl:Boolean = true;
		public var isTransmitting:Boolean = false; // true if player is undergoing transformation
		private var _isDaughterVisible:Boolean = false; // true once daughter becomes visible
		private var _isGrandChildVisible:Boolean = false;

		/**
		 * Fade Out
		 */
		public var fadeOutCurtain:Curtain;
		
		
		// Shutters 
		public var _shutterRight:Shutter;
		private var _shutterRightTween:NumTween;
		
		public var _shutterUp:Shutter;
		private var _shutterUpTween:NumTween;
		
		public var _shutterDown:Shutter;
		private var _shutterDownTween:NumTween;
		
		private var _shutterIsMoving:Boolean = false;
		private var _shutterModel:String = "";
		private const ONE_A:String = "1a";
		private const ONE_B:String = "1b";
		private const TWO:String = "2";
		
	
		public var shutterList:Vector.<Shutter>;
		
		
		/* RIGHT shutter*/
		public var shutterRightClosed:Number;					
		public var shutterRightMid:Number;
		public var shutterRightOpen:Number;
								
		/* UP shutter */
		public var shutterUpClosed:Number;					
		public var shutterUpMid:Number;
		public var shutterUpOpen:Number;
			
		/* DOWN shutter */
		public var shutterDownClosed:Number;					
		public var shutterDownMid:Number;
		public var shutterDownOpen:Number;
			
		
		
		/**
		 * For debug
		 */
		private var _counter:Number = 0;
		
		
		
		
		
		/************************************************
		 ************    CONSTRUCTOR      ***************
		 ************************************************/
		public function Player(_x:int=0, _y:int=0, _vb:Array=null) 
		{
			//call ancestor's construtor
			super();
			
			// place the entity's origin in the center of the path
			this.x = _x + 15;
			this.y = _y + 15;
			
			
			// layer
			layer = Layers.PLAYER;
			
			// set position vector as entity's coordinates
			position.x = this.x;
			position.y = this.y;
			
			// set initial player position as first previousPos
			previousPos = position.clone();
			
			// set the Entity's graphic property to a Spritemap object
			graphic = father;
			
			frames = new Array( 0, 1, 2, 3, 4, 5, 6, 7);

			framesChildAppear = new Array(0, 1, 2, 3, 4, 5, 6, 7, 8, 9);
			framesChildAlive = new Array(0, 1, 2, 3, 4, 5, 6, 7);
			framesFatherDeath = new Array(0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13);

			
			father.add("walk", frames, 12, true);
			child.add("walk", frames, 12, true);
			grandChild.add("walk", frames, 12, true);

			childAppear.add("appear", framesChildAppear, 2, false);
			childAlive.add("walk", framesChildAlive, 12, true);
			fatherDeath.add("die", framesFatherDeath, 2, false);
			
			// offset the graphic to center it at the netity's origin
			father.x = -15;
			father.y = -15;
			
			child.x = -15;
			child.y = -15;
			child.originX = 15;
			child.originY = 15;
			child.smooth = true;

			
			childAlive.x = -15;
			childAlive.y = -15;
			
			childAppear.x = -15;
			childAppear.y = -15;

			
			grandChild.x = -15;
			grandChild.y = -15;
			grandChild.originX = 15;
			grandChild.originY = 15;
			grandChild.smooth = true;
			
			// NOTE: if you're going down the route of fixed framrate, use 
			// avatar.add("walk", frames, 5*(1/FP.frameRate), true);
			
			//hitbox based on image size
			//set hitbox so it encapsulate the entity's origin
			offsetOriginX = 4;
			offsetOriginY = 4;
			var boxWidth:int = 8;
			var boxHeight:int = 8;
			
			setHitbox(boxWidth, boxHeight, offsetOriginX, offsetOriginY);
			
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
			COEFF_D_CHILD = LoadXmlData.COEFF_D_CHILD;
			COEFF_D_GRANDCHILD = LoadXmlData.COEFF_D_GRANDCHILD;
			
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
			
			
			//set all transmission timer alarms (one-shot alarms)
			timeToChild = new Alarm(TIMER_CHILD, onTimeToChild, 2);
			addTween(timeToChild, true); // add and start alarm
			
			timeFatherToDeath = new Alarm(TIMER_FATHERTODEATH, onTimeFatherToDeath, 2);
			addTween(timeFatherToDeath, true); // add and start alarm
			
			timeToGrandChild = new Alarm(TIMER_CHILDTOGRANDCHILD, onTimeToGrandChild, 2);
			addTween(timeToGrandChild, false); // add but don't start yet!
			
			timeGrandChildToEnd = new Alarm(TIMER_GRANDCHILDTOEND, onTimeGrandChildToEnd, 2);
			addTween(timeGrandChildToEnd, false); // add but don't start yet!
			
			timers.push(timeToChild, timeFatherToDeath,
				timeToGrandChild, timeGrandChildToEnd);
				
				
		}
		// END CONSTRUCTOR
		
		/**
		 * Initialize shutters for game
		 */
		public function shuttersAddToWorld(world:World):Vector.<Shutter>
		{
			_shutterRight = new Shutter(FP.width - 200, 0, "right");
			_shutterDown = new Shutter(0, FP.height - 120, "up");
			_shutterUp = new Shutter(0, 0, "up");
			
			shutterList = new Vector.<Shutter>();
			shutterList.push(_shutterDown, _shutterRight, _shutterUp);
			
			_shutterRightTween = new NumTween(shutterOnMoveComplete, 0);
			_shutterDownTween = new NumTween(shutterOnMoveComplete, 0);
			_shutterUpTween = new NumTween(shutterOnMoveComplete, 0);
			
			addTween(_shutterRightTween);
			addTween(_shutterDownTween);
			addTween(_shutterUpTween);
			
			/************************/
			/* Setup shutter presets*/
			/************************/
			
			/* RIGHT shutter*/
			shutterRightClosed = FP.width - 200;					
			shutterRightMid = FP.width - 100;
			shutterRightOpen = FP.width - 20;
						
			/* UP shutter */
			shutterUpClosed = -10;					
			shutterUpMid = - 40;
			shutterUpOpen =  - 110;
			

			/* DOWN shutter */
			shutterDownClosed = FP.height - 110;					
			shutterDownMid = FP.height - 80;
			shutterDownOpen = FP.height - 10;
			
			// add shutters to world
			world.addList(_shutterDown, _shutterRight, _shutterUp);
			
			return shutterList;
		}
		
		/**
		 * Debug info for persistent getCurrentPath bug
		 */
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
		 * Play music at game start, when object is instantiated
		 */
		override public function added():void
		{
			_pathPreviousIndex = getCurrentPath(); // find path player is on to play the correct file
			// debug if =3
			if (_pathPreviousIndex == 3) 
			{
				
				printDebugInfo(1);
				
			}
			
			// start playing path sound + music
			startSounds();
			
			// stop music on the player's starting path.. will resume once player starts moving
			//sound.pathSound[_pathPreviousIndex].stop();
			
			// intialize switch variables
			_pathSwitchTable[0] = _pathSwitchTable[1] = _pathPreviousIndex;
			_pathSwitchLocation = position.clone();
		}
		
		/**
		 * Initialize all sounds
		 */
		private function startSounds():void
		{
			// start all sounds but only turn up volume on current path
			for each (var music:Sfx in sound.pathSound) 
			{
					music.play(0); // set sound in motion with vol of zero
					music.stop(); // stop the music so that you can resume as soon as the player is moving
					
			}
			//trace("vol: " + sound.pathSound[_pathPreviousIndex].volume);

		}
		 
		
		
		/************************************
		 ******  PLAYER UPDATE LOOP *********
		 ************************************/
		override public function update():void 
		{
			// update debug game time counter
			_counter += FP.elapsed;
			
			// find out what path the player is on
			currentPathIndex = getCurrentPath();
			
			//debug if =3
			if (currentPathIndex == 3) 
			{
				
				printDebugInfo(2);
				
			}
			
			//store current path index
			if (_pathSwitched==false) 
			{
				_pathSwitchTable[0] = currentPathIndex;
			}
			
			// update speed on paths based on new pathDistance
			calculateSpeed(currentPathIndex);
			
			//check if a new animated tile needs to be placed where player has walked
			addNewTile(this.x, this.y, Path.TILE_GRID);
			
			// update movement status of player
			if (!wasMoving && isMoving) 
			{
				wasMoving = true;
			}
			
			if (wasMoving && !isMoving) 
			{
				wasMoving = false
			}
			
			// move player based on maximum speeds returned by the calculateSpeed method
			if (hasControl) 
			{
				move(currentPathIndex);
			}
			
			
			// update movement status of player
			if (!wasMoving && velocity.length) 
			{
				isMoving = true;
			}
			
			if (wasMoving && !velocity.length) 
			{
				isMoving = false
			}
			
			// fade sounds to ensure the correct path music is playing if the player is moving
			if (!deathImminent && !isTransmitting) 
			{
				playPathMusic(currentPathIndex);
			}

			
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
				if (_pathSwitchTable[0]!=_pathSwitchTable[1] && !isTransmitting && !deathImminent) // paths are still different after 30px
				{
					//trace("permanent path change");
					// play music based on current path and latest path change
					changePathMusic();
				}
				_pathSwitched = false;
				_pathSwitchClonedPosition = false;
				//trace("dist: " + Point.distance(position, _pathSwitchLocation));				
			}

			
			// calculate distance traveled since last frame and add to that path total
			distance = Point.distance(position, previousPos);
			pathDistance[currentPathIndex] += distance;
			
			// calculate distance traveled on all paths
			getTotalDistanceTravelled();
			
			// calculate path distance ratios
			getPathRatios();
			
			// play sprite animation
			animatePlayerSprite();
			
			//store current position as next previous position
			previousPos = position.clone();
			
			// scale player graphic if required
			scalePlayerSprite();		
			
			
			// check to see if it's time to make child appear
			if (robotFatherIsAlive) 
			{
				testChildAppear();
				testRemoveRobotFather();
			}
			
			// check to see if it's time to make grandChild appear
			if (robotDaughterIsAlive) 
			{
				testGrandChildAppear();
				testRemoveRobotDaughter();
			}
			
			// update shutter position
			shuttersUpdate();
			
			//update sound manager
			sound.update();

		}
		// end update()
		
		/**
		 * Play path music if player is moving
		 */
		private function playPathMusic(path:int):void
		{
			// FADE MUSIC IN
			if (isMoving && !wasMoving && !deathImminent) 
			{
				// player is moving, hence all music must play
				for each (var music:Sfx in sound.pathSound) 
				{
					// only resume the music if it was stopped
					if (!music.playing) 
					{
						music.resume();	
					}
					//trace("music state: " + music.playing);
				}
				
				// BUT only turn on the volume of the current path
				sound.pathFader[path].fadeTo(1, 1, Ease.quintIn);				
				
				//trace("fade path (" + path +") volume up");
				
			}
			// FADE MUSIC OUT
			else if (!isMoving && wasMoving && !deathImminent)
			{
				for each (var fader:SfxFader in sound.pathFader) 
				{
					fader.fadeTo(0, 1, Ease.sineOut);
				}
				// player stopped moving: fade out and stop all music (stop handled by onComplete in SoundManager)
				
				//trace("fade path (" + path +") volume down");
			}
	
			
			if (_counter>0.4) 
			{
				_counter -= _counter;
				for (var z:int = 0; z < 3; z++) 
				{
					/*trace("vol(" + z +"): " + sound.pathSound[z].volume.toFixed(1)
						+ "| scrub(" + z +"): " + sound.pathSound[z].position.toFixed(1)
						+ "| scale(" + z +"): "+ sound.pathFader[z].scale.toFixed(1));*/
				}
				//trace(" \n");
			}
		}
		
		/**
		 * fade the path music out
		 */
		public function fadeOutPathMusic(path:int):void
		{	
			if (sound.pathSound[path].volume != 0) 
			{
				sound.pathFader[path].fadeTo(0, 1);
			}
		}
		
		
		
		
		/**
		 * Change music track based on path changes
		 */
		private function changePathMusic():void
		{
			//compare the two stored path indexes (seperated by 30 pixels distance)
			//if they are different, then player has really changed path
			//as opposed to crossed an intersection
			if (_pathSwitchTable[1]!=_pathSwitchTable[0]) 
			{

				var idFrom:int = _pathSwitchTable[0];
				var idTo:int = _pathSwitchTable[1];
				fromSound = sound.pathFader[idFrom];
				toSound = sound.pathFader[idTo];
				
				//trace("start xfade");
				
				// fade out last path music
				//trace("playing sound: " + idFrom);

				fromSound.fadeTo(0, 1, Ease.sineOut);
				
				
				// fade in new path music
				//trace("moving to sound: " + idTo);

/*				if (!sound.pathSound[idTo].playing) 
				{
					toSound.sfx.resume();
					trace("resuming...");
				}*/
				
				for each (var music:Sfx in sound.pathSound) 
				{
					// only resume the music if it was stopped
					if (!music.playing) 
					{
						music.resume();
						trace("resuming...");
					}
					//trace("music state: " + music.playing);
				}
				
				toSound.fadeTo(1, 2, Ease.sineIn);
				
				
			}

		}
		
		
		/**
		 * Scale player graphic throughout its life
		 */
		private function scalePlayerSprite():void
		{
			if (graphic == child && timeToGrandChild.active) 
			{
				// map the time of child's life to the scale of it's sprite
				var mapped:Number = FP.scaleClamp(timeToGrandChild.remaining, timeToGrandChild.duration,
				(timeToGrandChild.duration / 2), _daughterMinSize, 1);
				
				child.scale = mapped;
				
			} else if(graphic == grandChild && timeGrandChildToEnd.active)
			{
				//map the time of grandchild's life to the scale of it's sprite
				var mapped2:Number = FP.scaleClamp(timeGrandChildToEnd.remaining,
				timeGrandChildToEnd.duration, 0, _grandChildMinSize, 1);
				
				grandChild.scale = mapped2;
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
			for (var m:int = 0; m < pathTileList.length; m++)
			{
				var value:PathTile = pathTileList[m];
				
				if (value.row==row && value.col == col) 
				{
					tileExists = true;
					break;
				}
				
				// remove tiles that are 200 pixels behind camra position
				if (value.x < (FP.camera.x - 200)) 
				{
					pathTileList.splice(m, 1);
					FP.world.remove(value);	
					m--;
				}
			}
			
			if (tileExists==false) 
			{
				// add new animated tile to Vector and Level
				var index:int = pathTileList.push(new PathTile(col, row, _step, currentPathIndex));
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
				if (totaldistance != 0) 
				{
					pathDistToTotalRatio[i] = pathDistance[i] / totaldistance;

				} else pathDistToTotalRatio[i] = 0;
			}
				//trace(distance);
				//trace(pathDistance[pathIndex]);
		}
		
		/**
		 * Moves the player based on keyboard inputs
		 * and velocities calculated in calculateSpeed()
		 */
		private function move(pathType:uint):void
		{
			// set local variables
			var e:Entity;
			var speed:Number;
			
			// reset velocity vector to zero
			velocity.x = 0;
			velocity.y = 0;
			
			//FOR DEBUG PURPOSES - STORE x,y before move
			var prev_x:Number = x;
			var prev_y:Number = y;
			
			
			//BUG the erratic bug may come from the fact that at high speeds I don't pixel-check move
			
			// check if god mode is on to set unique value for fast playthrough
			if (LoadXmlData.GODMODE==true) 
			{ 
				// use god speed
				speed = 3 * (FP.frameRate * FP.elapsed);	
			} 
			else 
			{
				// use normal velocity calculations
				speed = pathInstantVel[pathType] * (FP.frameRate * FP.elapsed);
			}
			
			
			if (Input.check("R"))
			{
				e = collideTypes(pathCollideType, x + speed, y);
				if (e)
				{
					velocity.x = speed;
				} else 
				{
					//trace("collided with entity: " + e);
					velocity.x = 0;
				}
				
			}
						
			if (Input.check("L"))
			{
				e = collideTypes(pathCollideType, x - speed, y);
				if (e)
				{
					if (LoadXmlData.GODMODE==true) 
						{ 
							// use god speed
							speed = 3 * (FP.frameRate * FP.elapsed);	
						} else speed = 0;
					
				} else 
				{
					//trace("collided with entity: " + e);
					velocity.x = 0;
				}	
			}
			
			if (Input.check("U"))
			{
				e = collideTypes(pathCollideType, x, y - speed);
				if (e)
				{
					velocity.y = -speed;
				} else 
				{
					//trace("collided with entity: " + e);
					velocity.y = 0;
				}
				
			}
			
			if (Input.check("D"))
			{
				e = collideTypes(pathCollideType, x, y + speed);
				if (e)
				{
					velocity.y = speed;
				} else 
				{
					//trace("collided with entity: " + e);
					velocity.y = 0;
				}	
				
			}
			
			// try and round the number, bug may be linked to rounding errors?	
			
			// add position to velocity vector
			position.x = x + velocity.x;
			position.y = y + velocity.y;
			
			// set new player x,y
			x = position.x;
			y = position.y;
			
			//DEBUG stuff for major bug
			var next_e:Entity = collideTypes(pathCollideType, x, y);

			if (!next_e) 
			{
				trace("CRASH: moved to an unacceptable position");
				trace("checked positive before move on type: " + e.type);
				//trace("checked after move and returned type: " + next_e.type);
				trace("prev_x: " + prev_x + "prev_y: " + prev_y);
				trace("vel_x: " +  velocity.x + "vel_y: " + velocity.y);
				trace("should move to x: " + (prev_x + velocity.x) + " y: " + (prev_y + velocity.y) );
				trace("new_x: " + x + "new_y: " + y);
				trace("moving player back to its previous position...");
				x = prev_x;
				y = prev_y;
			}
		}
		// end move()
		
		
		
		/**
		 * Calculate pllayer velocity based on path and state (father, child, grandchild)
		 */
		private function calculateSpeed(path:uint):void
		{			
			var coeff_type3:Number = 0.25;
			var DyDz:Number;
			var coeff_d_scurve:Number;
			
			// work out the combined distance of the two paths where previous avatar was slowest
			if (state=="child" || state=="grandChild") 
			{
				DyDz = pathDistance[transmitIndexY] + pathDistance[transmitIndexZ];
			}

			// store the fastest velocity out of the three paths	
			pathFastest = Math.max(pathMaxVel[0], pathMaxVel[1], pathMaxVel[2]);

			// ensure the right D is being used
			if (transmitModel==2) 
			{
				if (state=="child") 
				{
					coeff_d_scurve = COEFF_D_CHILD;
				} else if (state=="grandChild") 
				{
					coeff_d_scurve = COEFF_D_GRANDCHILD;
				}
			} else {
				coeff_d_scurve = COEFF_D;
			}
			
			// start loop
			for (var i:int = 0; i < 3; i++) 
			{
				// use s-curve calculations to figure out max velocity							
				// first map distance on path to s-curve significant numbers
				
				var mapped:Number = FP.scale(pathDistance[i], 0, D_MAX, S_MIN, S_MAX);
				pathMaxVel[i] = pathBaseSpeed[i] + coeff_d_scurve * (1 / (1 + Math.exp( -mapped)));
				
				// find out the greater of pathMaxVel and PathChildSpeed
				_maxPathSpeed[i] = Math.max(pathMaxVel[i], pathChildSpeed[i]);
				
				// if player is father or followed by robot child (before transmission)
				if (state=="father" || state=="childAlive") 
				{
					pathInstantVel[i] = pathMaxVel[i];
					typeVitesse[i] = "normale (pere)";
				}
				
				if ((state=="child" || state=="grandChild") && (transmitModel==0 || transmitModel == 1)) 
				{
					
					// check if type 3 comes into effect
					if (DyDz > (0.25 * Dxtotale) && !type3)
					{
															
						trace("Dz: " + pathDistance[transmitIndexZ].toFixed(2));
						trace("Dy: " + pathDistance[transmitIndexY].toFixed(2));
						trace("Dx: " + Dxtotale.toFixed(2));
						trace("DyDz: " + DyDz.toFixed(2));
						trace("0.25*Dx: " + (coeff_type3 * Dxtotale).toFixed(2));
						 
						
						trace("DyDz sup à  0.25 x Dxtotale - vitesse 3");	
						
						type3 = true;
						
					}
			
					if (type3) // must keep this speed till death 
					{
						pathInstantVel[i] = pathFastest;
						typeVitesse[i] = "V3 - Vmax des 3 chemins";
						//trace("V3 - Vmax des 3 chemins");
						
					} else if (pathMaxVel[i] < pathChildSpeed[i]) 
					{
						pathInstantVel[i] = pathChildSpeed[i];
						typeVitesse[i] = "V1 - constant (VB transmis)";	
						//trace("V1 - constant (VB transmis)");
					} 
					else if (pathMaxVel[i] >= pathChildSpeed[i]) 
					{
						typeVitesse[i] = "V2 - comme pere (vb+scurve)";
						pathInstantVel[i] = pathMaxVel[i];
						//trace("V2 - comme pere (vb+scurve)");
					} else 
					{
						trace ("wtf?");
					}
				}
				
				if ((state=="child" || state=="grandChild") && transmitModel==2) 
				{
					pathInstantVel[i] = pathMaxVel[i];
					typeVitesse[i] = "modele 2 - un seul type de vitesse (vb+d*scurve)";
				} 
			}
			
			//trace("type vitesse: " + typeVitesse[path]);
		}
		
		
		
		/**
		 * Handles animation based on current player state.
		 */
		private function animatePlayerSprite():void
		{
			// switch to the correct Spritemap to play the animation
			var who:Spritemap;
			
			switch (state) 
			{
				case "father":
					who = father;
					break;
				case "childAlive":
					who = childAlive;
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

				// map player velocity to framerate
				var scaleAnimSpeed:Number = FP.scaleClamp(Math.max(Math.abs(velocity.x), Math.abs(velocity.y)), 0, 2, 0, 1);	
				who.rate = scaleAnimSpeed * FP.frameRate * FP.elapsed;
				
			} else {
				
				// freeze the animation
				who.setFrame(0);
			}
		}
		

		
		/**
		 * event handler once child-appear animation has stopped playing
		 */
		public function onChildAppearComplete():void
		{
			// swap childAppear sprite with childAlive sprite and give control back to player
			graphic = childAlive;
			hasControl = true;
			childAlive.play("walk");
		}
		
		
		/**
		 * event handler once father death animation has stopped playing
		 */
		public function onFatherDeathComplete():void
		{
			isFatherDying = false;
			trace("oh, shit, father just went awol...");
		}
		
		
		
		/**
		 * Method that triggers the change from father to child
		 * 
		 */
		public function fatherDeathSequence():void
		{
			// remove control from player
			hasControl = false;
			
			// set status to dying (used to check frames and make child appear at the rigth time)
			isFatherDying = true;
			
			// add a robot with death animation
			robotFather = new Robot(x, y, "fatherDeath");
			FP.world.add(robotFather)
			robotFather.robotFatherDeath.play("die");
			robotFatherIsAlive = true;
			
			// change player sprite to child and set to invisible
			graphic = child;
			child.alpha = 0;
			graphic.visible = false;
				
		}
		
		/**
		 * Method that triggers the change form child(daughter) to grandchild
		 */
		public function daughterDeathSequence():void
		{
			// remove control from player
			hasControl = false;
			
			// set status to dying (used to check frames and make child appear at the rigth time)
			isDaughterDying = true;
			
			// add a robot with death animation
			robotDaughter = new Robot(x, y, "robotdaughter");
			FP.world.add(robotDaughter)
			robotDaughter.robotDaughterDeath.play("push");
			robotDaughterIsAlive = true;
			
			// change player sprite to grandChild and set to invisible
			graphic = grandChild;
			grandChild.alpha = 0;
			graphic.visible = false;
			
		}

		
		/**
		 * Test to see if it's the right time to make the child appear
		 */
		private function testChildAppear():void
		{
			if (robotFather.robotFatherDeath.frame == 12 && !_isDaughterVisible) 
			{
				makeChildVisible();
				trace("child visible");
			}
		}
		
		/**
		 * Test to see if it's the right time to make the grandChild appear
		 */
		private function testGrandChildAppear():void
		{
			if (robotDaughter.robotDaughterDeath.frame == 23 && !_isGrandChildVisible) 
			{
				makeGrandChildVisible();
				trace("grand child visible");
			}
		}
		
		/**
		 * If robot fade out is complete, remove from world
		 */
		public function testRemoveRobotFather():void
		{
			if (robotFather.remove) 
			{
				//BUG removing father removes background image!
				//FP.world.remove(robotFather);
				robotFatherIsAlive = false;
				trace("removed robot father from world");
			}
		}
		
		/**
		 * If robot fade out is complete, remove from world
		 */
		public function testRemoveRobotDaughter():void
		{
			if (robotDaughter.remove) 
			{
				//BUG removing daughter removes path spritemap
				//FP.world.remove(robotDaughter);
				robotDaughterIsAlive = false;
				trace("removed robot daughter from world");
			}

		}
		
		/**
		 * once the father is almost dead, child fades in
		 */
		public function makeChildVisible():void
		{
			//make player child graphic visible 
			graphic.visible = true;
			child.scale = _daughterMinSize;
			
			// tween its alpha value
			var alphaTween:VarTween = new VarTween(null, 2);
			alphaTween.tween(this.child, "alpha", 1, 1);
			addTween(alphaTween);
			alphaTween.start();	
			
			_isDaughterVisible = true;
		}
		
		/**
		 * once the father is dead, player takes control of child
		 */
		public function makeGrandChildVisible():void
		{
			//make player child graphic visible 
			graphic.visible = true;
			grandChild.scale = _grandChildMinSize;
			
			// tween its alpha value
			var alphaTween:VarTween = new VarTween(null, 2);
			alphaTween.tween(this.grandChild, "alpha", 1, 1);
			addTween(alphaTween);
			alphaTween.start();
			
			_isGrandChildVisible = true;

		}
		
		/**
		 * Player is undergoing transformtion. Start countdown.
		 * @param	length	duration of transmition in seconds
		 */
		public function startTransmitionTimer(length:Number):void
		{
			transmitTimer = new Alarm(length, onTransmitTimerComplete, 2);
			addTween(transmitTimer);
			transmitTimer.start();
			
			isTransmitting = true;
			
			// remove control from player
			hasControl = false;
			trace("start transmition timer");
		}
		
		private function onTransmitTimerComplete():void
		{
			isTransmitting = false;
			
			// return control to player
			hasControl = true;
			trace("transmition complete");
			
			//transmit properties from father to child
			transmitFatherToChild();
			
			trace("state: " + state);
			
			if (state == "childAlive") 
			{
				//start countdown to grandchild transmission
				timeToGrandChild.start();
				trace("start timeToGrandChild alarm");		
				//set player state to child
				state = "child";
				trace("has control of child");
			}
			else if (state == "child") 
			{
				// start final countdown to end
				// will check in Game update to start death sequence before end
				timeGrandChildToEnd.start();
						
				//set player state to child
				state = "grandChild";
				trace("has control of grand child");
			}
			
		}
		
		/**
		 * Calculate the path ratios
		 */
		public function calculatePathRatios():void
		{
			ratioRouge = pathDistToTotalRatio[0]; 
			ratioVert = pathDistToTotalRatio[1]; 
			ratioBleu = pathDistToTotalRatio[2];
			_maxPathRatio = Math.max(ratioRouge,ratioVert,ratioBleu);
			_minPathRatio = Math.min(ratioRouge,ratioVert,ratioBleu);
		}
		
		/**
		 * 
		 * @return array of (distance path/total distance) sorted in ascending order
		 */
		private function getClassementPath():Array
		{

			return pathDistToTotalRatio.sort(Array.RETURNINDEXEDARRAY); // will return in ascending order			
		}
		
		public function getRatx():Number
		{
			return Math.max(ratioRouge, ratioVert, ratioBleu); // ratio du chemin le plus parcouru
		}
		
		public function getRatz():Number
		{
			return Math.min(ratioRouge, ratioVert, ratioBleu); // ratio du chemin le moins parcouru
		}
		
		/**
		 * Calculs de transmission
		 */
		public function transmitFatherToChild():void
		{		
			var ratx:Number = getRatx();
			var ratz:Number = getRatz();
			var classement:Array = getClassementPath();
			
			// debug stuff
			for (var h:int = 0; h < 3; h++) 
			{
				trace("classement: " + classement[h]);
				switch (h) 
				{
					case 0:
						trace("ratio z: " + pathDistToTotalRatio[classement[h]]);
						break;
					case 1:
						trace("ratio y: " + pathDistToTotalRatio[classement[h]]);
						break;
					case 2:
						trace("ratio x: " + pathDistToTotalRatio[classement[h]]);
						break;
				}

			}
			
			// Modèle 1-a: 0.6<ratx<1 et 0=<ratz<0.2
			if (ratx > 0.6 && ratz < 0.2)
			{
				// set child special speed
				pathChildSpeed[classement[2]] = CT_VB + 0.8 * ratx;
				pathChildSpeed[classement[1]] = VB - 0.2 * ratx;
				pathChildSpeed[classement[0]] = VB - 0.2 * ratx;
				
				// reset base speed to VB
				for (var j:int = 0; j < pathBaseSpeed.length; j++) 
				{
					pathBaseSpeed[j] = VB;
				}
				transmitModel = 0;
				trace("Modèle 1a");
			} 
			// Modèle 1-b: 0.43=<ratx=<0.6 et 0=<ratz<0.15
			else if (ratx >= 0.43 && ratx <= 0.6 && ratz <= 0.15)
			{
				// set child special speed
				pathChildSpeed[classement[2]] = CT_VB + 0.6 * ratx;
				pathChildSpeed[classement[1]] = VB;
				pathChildSpeed[classement[0]] = VB;
				// reset base speed to VB
				for (var m:int = 0; m < pathBaseSpeed.length; m++) 
				{
					pathBaseSpeed[m] = VB;
				}
				trace("Modèle 1b");
				transmitModel = 1;
			}
			// Modèle 2: 0.34=<ratx=<0.6 et 0.15=<ratz<0.33
			else if (ratx >= 0.34 && ratx <= 0.6 && ratz >= 0.15 && ratz <= 0.33)
			{ 
				// set child special speed
				pathChildSpeed[classement[2]] = VB;
				pathChildSpeed[classement[1]] = VB;
				pathChildSpeed[classement[0]] = VB;
				
				// reset base speed to VB
				for (var k:int = 0; k < pathBaseSpeed.length; k++) 
				{
					pathBaseSpeed[k] = VB;
				}
				transmitModel = 2;
				trace("Modèle 2");
			}
			else
			{
				trace("cas moyen!");
			}
      
			for (var i:int = 0; i < 3; i++) {
				trace("nouvelle VB: ("+ i + ") " + pathChildSpeed[i]);
			}
			
			// remettre toues les distances à zero
			for (var s:int = 0; s < 3; s++) 
			{
				//store distances and velocities
				if (state == "father" || state == "childAlive") 
				{
					fatherStoredDistances[s] = pathDistance[s];
					fatherStoredVelocities[s] = pathMaxVel[s];
				} else	{
					childStoredDistances[s] = pathDistance[s];
					childStoredVelocities[s] = pathMaxVel[s];
				}
	
				//reset distances to zero
				pathDistance[s] = 0;
			}
			
			
			var sortpaths:Array = new Array();
			var sortspeeds:Array = new Array();
			
			// transmettre les index de chemin pour calcul de vitesse _type3
			if (state == "father" || state == "childAlive") 
			{
				// calculate all the stuff needed to set-up _type3 velocities
				sortpaths = fatherStoredDistances.sort(Array.RETURNINDEXEDARRAY | Array.DESCENDING | Array.NUMERIC); // sort in descending order
				Dxtotale = fatherStoredDistances[sortpaths[0]]; //store the highest value DxTotal
				
				sortspeeds = fatherStoredVelocities.sort(Array.RETURNINDEXEDARRAY | Array.DESCENDING | Array.NUMERIC); // sort in descending order
				// sortspeeds[1] and [2] are the slowest paths of the father at transmission
				
				transmitIndexY = sortspeeds[1];
				transmitIndexZ = sortspeeds[2];

				trace("pere -> fils");
				trace("chemin le plus emprunté: " + sortpaths[0]);
				trace("Dxtotale: " + Number(Dxtotale).toFixed(1));
				trace("chemins les plus lents: " + transmitIndexY + " " + transmitIndexZ);
				trace("distance sur ces chemins: " + Number(fatherStoredDistances[sortpaths[1]]).toFixed(1) + " " + Number(fatherStoredDistances[sortpaths[2]]).toFixed(1));
				

			} else {
				
				// calculate all the stuff needed to set-up _type3 velocities
				sortpaths = childStoredDistances.sort(Array.RETURNINDEXEDARRAY | Array.DESCENDING | Array.NUMERIC); // sort in descending order
				Dxtotale = childStoredDistances[sortpaths[0]]; //store the highest value DxTotal
			
				
				sortspeeds= childStoredVelocities.sort(Array.RETURNINDEXEDARRAY | Array.DESCENDING | Array.NUMERIC); // sort in descending order
				// sortspeeds[1] and [2] are the slowest paths of the father at transmission
				
				transmitIndexY = sortspeeds[1];
				transmitIndexZ = sortspeeds[2];

				trace("fils -> petit_fils");
				trace("chemin le plus emprunté: " + sortpaths[0]);
				trace("Dxtotale: " + Number(Dxtotale).toFixed(1));
				trace("chemins les plus lents: " + transmitIndexY + " " + transmitIndexZ);
				trace("distance sur ces chemins: " + Number(childStoredDistances[sortpaths[1]]).toFixed(1) + " " + Number(childStoredDistances[sortpaths[2]]).toFixed(1));

			}
			
			// reset _type3 for next transmission
			type3 = false;
			
			
		} 
		// end transmitFatherToChild()
		
		/**
		 * Update shutter positions
		 */
		public function shuttersUpdate():void
		{
			var debug:Boolean = true;
			var maxR:Number = getRatx();
			var minR:Number = getRatz();			
			var triggerLimit:Number = 1000;
			
			// check to see which model to move to based on player state
			if (state == "father" && totaldistance < triggerLimit) 
			{
				_shutterRight.x = FP.camera.x + shutterRightClosed;
				_shutterUp.x = FP.camera.x;
				_shutterDown.x = FP.camera.x;
				
				
			} else if (state == "father" || state == "childAlive") 
			{
				// move to model 1A
				if (maxR > 0.6 && minR < 0.2)
				{
					if (!_shutterIsMoving && _shutterModel != ONE_A) 
					{
						shuttersModelOneA();
						trace("moving to shutters 1a");
					}
					
					
				}
				// move to model 1B
				else if (maxR >= 0.43 && maxR <= 0.6 && minR <= 0.15) 
				{
					if (!_shutterIsMoving && _shutterModel != ONE_B) 
					{
						shuttersModelOneB();
					}
					
				}
				// move to model 2
				else if (maxR >= 0.34 && maxR <= 0.6 && minR >= 0.15 && minR <= 0.33) 
				{
					if (!_shutterIsMoving && _shutterModel != TWO) 
					{
						shuttersModelTwo();
					}
					
				}
				
				// update shutter positions
				shuttersMove();	
			}
									
		}
		
		/**
		 * move shutters to the tweened position
		 */
		public function shuttersMove():void
		{
			_shutterRight.x = FP.camera.x + Math.ceil(_shutterRightTween.value);
			_shutterRight.y = 0;	
			
			
			_shutterUp.x = FP.camera.x;
			_shutterUp.y = Math.ceil(_shutterUpTween.value);
			
			_shutterDown.x = FP.camera.x;
			_shutterDown.y = Math.ceil(_shutterDownTween.value);

		}
		
		/**
		 * Called when any of the shutter tweens are complete
		 */
		public function shutterOnMoveComplete():void
		{
			_shutterIsMoving = false;
		}

		
		/**
		 * Move shutters to closed position
		 */
		public function shuttersOpen():void
		{
			var debug:Boolean = true;
			_shutterIsMoving = true;
			
			/* RIGHT shutter */
			_shutterRightTween.tween((_shutterRight.x-FP.camera.x), shutterRightOpen, 4, Ease.sineIn);
			_shutterRightTween.start();
				
			/* UP shutter */
			_shutterUpTween.tween(_shutterUp.y, shutterUpOpen, 4, Ease.sineIn);
			_shutterUpTween.start();
					
			/* DOWN shutter */		
			_shutterDownTween.tween(_shutterDown.y, shutterDownOpen, 4, Ease.sineIn);
			_shutterDownTween.start();
			
		}
		
		/**
		 * Move shutters to open position
		 */
		public function shuttersClose():void
		{
			var debug:Boolean = true;
			_shutterIsMoving = true;
			
			/* RIGHT shutter */
			_shutterRightTween.tween((_shutterRight.x-FP.camera.x), shutterRightClosed, 4, Ease.sineIn);
			_shutterRightTween.start();
				
			/* UP shutter */
			_shutterUpTween.tween(_shutterUp.y, shutterUpClosed, 4, Ease.sineIn);
			_shutterUpTween.start();
					
			/* DOWN shutter */		
			_shutterDownTween.tween(_shutterDown.y, shutterDownClosed, 4, Ease.sineIn);
			_shutterDownTween.start();
		}
		
		/**
		 * Move shutters to position 1a
		 */
		public function shuttersModelOneA():void
		{
			var debug:Boolean = true;
			_shutterIsMoving = true;
			_shutterModel = ONE_A;
			
			/* RIGHT shutter */
			_shutterRightTween.tween((_shutterRight.x-FP.camera.x), shutterRightOpen, 4, Ease.sineIn);
			_shutterRightTween.start();
			
				
			/* UP shutter */
			_shutterUpTween.tween(_shutterUp.y, shutterUpClosed, 4, Ease.sineIn);
			_shutterUpTween.start();
					
			/* DOWN shutter */		
			_shutterDownTween.tween(_shutterDown.y, shutterDownClosed, 4, Ease.sineIn);
			_shutterDownTween.start();
				
				
			//debug
			if (_counter > 0.4 && debug) 
			{
				_counter -= _counter;
				trace("modele 1a");
					
				if (_shutterRightTween.active) 
				{
					trace(_shutterRightTween.value);
				}
			}
		}
		
		/**
		 * Move shutters to position 1b
		 */
		public function shuttersModelOneB():void
		{
			var debug:Boolean = true;
			_shutterIsMoving = true;
			_shutterModel = ONE_B;
			
			/* RIGHT shutter */
			_shutterRightTween.tween((_shutterRight.x-FP.camera.x), shutterRightMid, 4, Ease.sineIn);
			_shutterRightTween.start();
				
			/* UP shutter */
			_shutterUpTween.tween(_shutterUp.y, shutterUpMid, 4, Ease.sineIn);
			_shutterUpTween.start();
				
			/* DOWN shutter */					
			_shutterDownTween.tween(_shutterDown.y, shutterDownMid, 4, Ease.sineIn);
			_shutterDownTween.start();
			
				
			//debug
			if (_counter > 0.4 && debug) 
			{
				_counter -= _counter;
				trace("modele 1b");
					
				if (_shutterRightTween.active) 
				{
					trace(_shutterRightTween.value);
				}
			}
		}
		
		/**
		 * Move shutters to position 2
		 */
		public function shuttersModelTwo():void
		{
			var debug:Boolean = true;
			_shutterIsMoving = true;
			_shutterModel = TWO;
			
			/* RIGHT shutter */
			_shutterRightTween.tween((_shutterRight.x-FP.camera.x), shutterRightClosed, 4, Ease.sineIn);
			_shutterRightTween.start();
			
			/* UP shutter */
			_shutterUpTween.tween(_shutterUp.y, shutterUpOpen, 4, Ease.sineIn);
			_shutterUpTween.start();
				
			/* DOWN shutter */		
			_shutterDownTween.tween(_shutterDown.y, shutterDownOpen, 4, Ease.sineIn);
			_shutterDownTween.start();
			
						
			//debug
			if (_counter > 0.4 && debug) 
			{
				_counter -= _counter;
				trace("modele 2");
				
				if (_shutterRightTween.active) 
				{
					trace(_shutterRightTween.value);
				}
			}
		}
		
		
		
		
		
		/**
		 * Child appears with father
		 */
		public function onTimeToChild():void
		{
			// kill all path music
			for (var i:int = 0; i < 3; i++) 
			{
				fadeOutPathMusic(i);
			}

			
			// child appears as a robot. Nothing transmitted yet.
			state = "childAlive";

			// remove control from player
			hasControl = false;
			
			// swap father sprite for child appear sprite
			graphic = childAppear;
			childAppear.play("appear");
			
		}
		
		/**
		 * Make father disapear and child appear
		 */
		public function onTimeFatherToDeath():void
		{
			// kill the path music
			for (var i:int = 0; i < 3; i++) 
			{
				fadeOutPathMusic(i);
			}
			
			// start the transmition timer
			startTransmitionTimer(LoadXmlData.TRANS_TIMER);
			
			// trigger the father death sequence
			fatherDeathSequence();
			
			// cue-in jingle
			sound.transmitJingle.play();
		}
		
	
		
		/**
		 * Transmit child to grandchild
		 */
		public function onTimeToGrandChild():void
		{
			// kill the path music
			for (var i:int = 0; i < 3 ; i++) 
			{
				fadeOutPathMusic(i);
			}

			
			// start the transmition timer
			startTransmitionTimer(LoadXmlData.TRANS_TIMER);
			
			// trigger the daughter death sequence
			daughterDeathSequence();
			
			// cue-in jingle
			sound.transmitJingle.play()

		}
		
		/**
		 * Death of grandchild and game end
		 */
		public function onTimeGrandChildToEnd():void
		{
						
			trace("grandchild is dead");
			isPlayerDead = true;

			// see if this helps kill the sounds
			//playerGoneAWOL = true;
			
			// kill all sounds
			for each (var soundToKill:Sfx in sound.pathSound) 
			{
				if (soundToKill.playing) 
				{

					soundToKill.stop();
				}
			}
			
			// remove sound object from world
			FP.world.remove(sound);
			
			// fade out from game
			fadeOutGame();
			
			// remove player from game
			FP.world.remove(this);

		}
		
		private function fadeOutGame():void
		{
			// send Outro
			fadeOutCurtain = new Curtain(FP.width + 10, FP.height, "out");
			fadeOutCurtain.x = FP.camera.x;
			fadeOutCurtain.y = FP.camera.y;
			
			FP.world.add(fadeOutCurtain);
			trace("fade out");
		}
		
		
		/**
		 * Method to test if player has just released the right arrow
		 */
		public function rightArrowReleased():Boolean
		{
			return Input.released("R");
			
		}
	}
}