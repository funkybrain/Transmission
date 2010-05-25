package game 
{
	import ai.Pathfinder;
	import ai.SquareGrid;
	
	public class FindPath
	{
				
		private var _grid:SquareGrid;
		private var _node:Object;
		private var _path:Pathfinder;
		private var _start:Object;
		private var _goals:Object;
		
		
		public function FindPath() 
		{
			// testing ai shit
			doAIShit();
		}
		
		public function doAIShit():void
		{
			_grid = new SquareGrid(100, 15, 30);
			
			_node = new Object();
			_node.u = 1;
			_node.v = 2;
			
			_start = { u:3, v:4 } // the start node
			_goals = { u:75, v:10 } // the goal node
			
			
			_path = new Pathfinder(_grid, _start, _goals, _heuristic, _cost);
			
			if (_path.findPath()) 
			{
				_path.path.reverse();
				
				for (var j:int = 0; j < _path.path.length; j++) 
				{
					trace("node u:v" + _path.path[j].u + ":" + _path.path[j].v);	
				}
				
				//Draw.rect(_path.path[j].u*_grid.size, _path.path[j].v*_grid.size, _grid.size, _grid.size)
				
			}
			
			// next figure out how to add node where father becomes a robot
			// and then just move him along the path
		}
		
		// this is g in f = g + h
		private function _cost(n1:Object, n2:Object):Number
		{
			return 10; // assume fixed cost every direction
			
			// will need to test what node n2 is and return Infinity if it's not traversable
			// e.g. test to see is n2 is on a path or not by comparing against
			// all the grid.sectRect used in the Path classes
			// (might be faster checking for collision instead??)
			
			// if on a path, cost = 10 (or speed of path if you want more complex stuff)
			// else cost = Infinity
		}
		
		// this is h in f = g + h
		private function _heuristic(n1:Object, n2:Object):Number
		{
			var h:Number = 10 * _grid.distance(n1, n2) * _grid.size; // Manhattan method with factor of 10
			return h;
		}
		
	}

}