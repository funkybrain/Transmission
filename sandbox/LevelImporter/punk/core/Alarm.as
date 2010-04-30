package punk.core 
{
	/**
	 * Frame-based timer component, used for managing the game pace, timed events, etc.
	 * All Objects that extend Core (World, Entity, Actor, etc.) can carry, update and trigger Alarms.
	 * @see punk.core.Core
	 */
	public class Alarm 
	{
		/**
		 * A ONESHOT-type Alarm will fire only once, and remove itself immediately after.
		 * @see #type
		 */
		public static const ONESHOT:int = 0;
		
		/**
		 * A LOOPING-type Alarm will continue firing at its specified interval until you manually stop it.
		 * @see #type
		 */
		public static const LOOPING:int = 1;
		
		/**
		 * A PERSIST-type Alarm will trigger once and then stop, but remain idle instead. Since it does not remove itself, you can manually start it again.
		 * @see #type
		 */
		public static const PERSIST:int = 2;
		
		/**
		 * How many frames it will take the alarm to fire after it starts.
		 */
		public var totalFrames:int;
		
		/**
		 * How many more frames the alarm has to go before it fires.
		 */
		public var remainingFrames:int;
		
		/**
		 * The function that the alarm will call when it fires.
		 */
		public var call:Function;
		
		/**
		 * The alarm type, which specifies what the alarm should do when it fires.
		 * @see #ONESHOT
		 * @see #LOOPING
		 * @see #PERSIST
		 */
		public var type:int;
	
		/**
		 * You can specify the Alarm interval, callback function, and type in its constructor.
		 * 
		 * <p><strong>NOTE:</strong> Alarms do not start themselves automatically, they will only start when you call their start() function.</p>
		 * @param	frames	How many frames the alarm should wait before firing.
		 * @param	call	The function that the alarm will call when it fires.
		 * @param	type	The alarm type, which specifies what the alarm should do when it fires.
		 * @see #start()
		 * @see #totalFrames
		 * @see #call
		 * @see #type
		 */
		public function Alarm(frames:int, call:Function, type:int = 0) 
		{
			_added = _running = false;
			set(frames, call, type);
		}
		
		/**
		 * Sets all the parameters of the alarm and resets it.
		 * @param	frames	How many frames the alarm should wait before firing.
		 * @param	call	The function that the alarm will call when it fires.
		 * @param	type	The alarm type, which specifies what the alarm should do when it fires.
		 * @return	This Alarm object.
		 */
		public function set(frames:int, call:Function, type:int = 0):Alarm
		{
			remainingFrames = totalFrames = frames;
			this.call = call;
			this.type = type;
			return this;
		}
		
		/**
		 * Starts the alarm, restarting it from the beginning if it has stopped or is already running.
		 * @return	This Alarm object.
		 */
		public function start():Alarm
		{
			_running = true;
			remainingFrames = totalFrames;
			return this;
		}
		
		/**
		 * Resumes the alarm if it has stopped.
		 * @return	This Alarm object.
		 */
		public function resume():Alarm
		{
			if (type == LOOPING && !remainingFrames) remainingFrames = totalFrames;
			_running = true;
			return this;
		}
		
		/**
		 * Stops the alarm while running, so it will not fire.
		 * @return	This Alarm object.
		 */
		public function stop():Alarm
		{
			_running = false;
			return this;
		}
		
		/**
		 * Whether this Alarm is running or not.
		 */
		public function get isRunning():Boolean
		{
			return _running;
		}
		
		/**
		 * Whether the alarm has fired and is no longer running.
		 */
		public function get isFinished():Boolean
		{
			return !_running && !remainingFrames;
		}
		
		/** @private */
		internal function update():void
		{
			var a:Alarm = this,
				n:Alarm = this;
			while (a)
			{
				n = a._next;
				if (a._running)
				{
					a.remainingFrames --;
					if (!a.remainingFrames)
					{
						a._entity.alarmLast = a;
						if (a.type == ONESHOT)
						{
							// stop and remove the alarm
							if (a._next) a._next._prev = a._prev;
							if (a._prev) a._prev._next = a._next;
							if (a._entity._alarmFirst == a) a._entity._alarmFirst = a._next;
							a._next = a._prev = null;
							a._entity = null;
							a._added = a._running = false;
						}
						else if (a.type == LOOPING)
						{
							// reset the alarm automatically
							a.remainingFrames = a.totalFrames;
						}
						else if (a.type == PERSIST)
						{
							// just stop the alarm, but keep it in the list
							a._running = false;
						}
						a.call();
					}
				}
				a = n;
			}
		}
		
		// alarm properties
		/** @private */ internal var _added:Boolean;
		/** @private */ internal var _running:Boolean;
		/** @private */ internal var _entity:Core;
		/** @private */ internal var _prev:Alarm;
		/** @private */ internal var _next:Alarm;
	}
}