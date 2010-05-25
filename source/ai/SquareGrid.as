// Square grid for A* Demonstration
// Copyright 2007 Amit J Patel, amitp@cs.stanford.edu
// License: MIT (see LICENSE file)

package ai
{
    import ai.Graph;
    import flash.geom.Point;
    
    public class SquareGrid extends Graph {
        public var size:int; // side of a square, in pixels
        public var width:int; // number of squares across
        public var height:int; // number of squares high

        public function SquareGrid(width_:int, height_:int, size_:int) {
            width = width_;
            height = height_;
            size = size_;
        }
        
        /**
         * 
         * @return an array of dimension width x height with the index (u, v) for each node (node = square in this case)
         */
		override public function allNodes():Array {
            var result:Array = new Array();
            for (var u:int = 0; u != width; u++) {
                for (var v:int = 0; v != height; v++) {
                    result.push({ u: u, v: v });
                }
            }
            return result;
        }
        
		/**
		 * 
		 * @return the coordinate of the central square of the grid
		 * 
		 * god knows what for!!
		 */
        override public function centerNode():Object {
            return { u: Math.floor(width/2), v: Math.floor(height/2) };
        }
		
		/**
		 * 
		 * @param	n	is a node object (associative array / hash table) with keys/properties (u, v)
		 * @return		a string of the node's coordinates "u,v"
		 */
        override public function nodeToString(n:Object):String {
            return ""+n.u+","+n.v;
        }
        
		/**
		 * 
		 * @param	s	a string representing a node's coordinates in the grid "u, v"
		 * @return		an associative array (object) with keys u, v
		 */
        override public function stringToNode(s:String):Object {
            var fields:Array = s.split(",", 2);
            return {u: Number(fields[0]), v: Number(fields[1])};
        }
        
		/**
		 * 
		 * @param	n1	a node Object (associative array)
		 * @param	n2	another node
		 * @return		true if n1 is equal to n2 (same grid position)
		 */
        override public function nodesEqual(n1:Object, n2:Object):Boolean {
            return (n1.u == n2.u) && (n1.v == n2.v);
        }
        
		/**
		 * 
		 * @param	n	a node Object
		 * @return		an associative array (this time, an Array and not an Object) that stores all the vertices of the node
		 * 
		 * This assumes the vertex defining one grid square is the top-left corner
		 * --(u,v)-*----*-(u+1,v)
		 *         |    |
		 * (u,v+1)-*----*-(u+1, v+1)
		 * 
		 */
        override public function nodeVertices(n:Object):Array {
            return new Array({ u: n.u, v: n.v },
                             { u: n.u+1, v: n.v },
                             { u: n.u+1, v: n.v+1 },
                             { u: n.u, v: n.v+1 });
        }
        
        /**
         * 
         * @param	v	a node Object with keys u, v
         * @return		a Point(u*size, v*size) that represents the coordinate of the node's vertex in the grid
         */
		override public function vertexGeom(v:Object):Point {
            return new Point(v.u * size, v.v * size);
        }
        
		/**
		 * 
		 * @param	n	a node Object with keys u, v
		 * @return		true if the node is within the grid bounds
		 */
        override public function nodeValid(n:Object):Boolean {
            return (0 <= n.u && n.u < width && 0 <= n.v && n.v < height);
        }
        
		/**
		 * 
		 * @param	p	a point representing the coordinate of the vertex in the grid
		 * @return		a node object with keys u, v representing the position of the node on the grid
		 */
        override public function pointToNode(p:Point):Object {
            // optimization of what the base class would do
            var u:Number = p.x / size;
            var v:Number = p.y / size;
            if (nodeValid({u: u, v: v})) {
                return { u: Math.floor(u), v: Math.floor(v) };
            } else {
                return null;
            }
        }
        
		/**
		 * 
		 * @param	n	a node Object with keys u, v
		 * @return		an associative array with keys u, v that stores all neighbouring nodes on grid
		 */
        override public function nodeNeighbors(n:Object):Array {
            var r:Array = new Array({ u: n.u + 1, v: n.v },
                                    { u: n.u, v: n.v + 1 },
                                    { u: n.u - 1, v: n.v },
                                    { u: n.u, v: n.v - 1 });
            var result:Array = new Array();
            for (var i:int = 0; i != r.length; i++) {
                if (nodeValid(r[i])) {
                    result.push(r[i]);
                }
            }
            return result;
        }
		
		/**
		 * 
		 * @param	a	a node Object
		 * @param	b	a node Object
		 * @return		the distance (in terms of grid steps) between these two nodes
		 */
        override public function distance(a:Object, b:Object):Number {
            return Math.abs(a.u - b.u) + Math.abs(a.v - b.v);
        }
    }
}
