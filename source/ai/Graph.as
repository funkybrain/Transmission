// Graph class for A*
// Copyright 2007 Amit J Patel, amitp@cs.stanford.edu
// License: MIT (see LICENSE file)

// Base class for graphs.  A graph is a set of Nodes and edges (links
// to other nodes).  Each Node is represented as an object (typically
// a record containing coordinates).  The graph class also defines a
// 2d polygonal representation of Nodes.  For hashing purposes, the
// graph class must define nodeToString to return a unique string for
// each node.  I'm using graphs instead of grids as a base because it
// makes certain problems easier to understand and solve, although
// sometimes the solutions are less efficient. See
// http://scienceblogs.com/goodmath/2007/09/puzzling_graphs_problem_modeli.php
// for an example.

package ai
{
    import flash.geom.Point;
                           
    public class Graph {
        public function allNodes():Array { return new Array(); }
        public function centerNode():Object { /* Abstract */ return null; }
  
        public function vertexGeom(v:Object):Point {
            return new Point(0.0, 0.0);
        }
		
		/**
		 * 
		 * @param	n	a Node object
		 * @return		takes each vertice of a Node and store it's coordinates as a array of Points
		 */
        public function nodeGeom(n:Object):Array {
            var results:Array = new Array();
            var nodes:Array = nodeVertices(n);
            for (var i:int = 0; i != nodes.length; i++) {
                results.push(vertexGeom(nodes[i]));
            }
            return results;
        }
        
		/**
		 * 
		 * @param	n	a Node object
		 * @return		returns the center coordinate of a Node as a Point?
		 */
        public function nodeCenter(n:Object):Point {
            var center:Point = new Point(0.0, 0.0);
            var nodes:Array = nodeVertices(n);
            for (var i:int = 0; i != nodes.length; i++) {
              center = center.add(vertexGeom(nodes[i]));
            }
            return new Point(center.x / nodes.length, center.y / nodes.length);
        }

        public function nodeValid(n:Object):Boolean { return false; }

        public function nodeToString(n:Object):String { /* Abstract */ return ""; }
        public function stringToNode(s:String):Object { /* Abstract */ return null; }
        public function nodesEqual(n1:Object, n2:Object):Boolean { /* Abstract */ return false; }
        public function nodeVertices(n:Object):Array { /* TODO: */ return null; }
        public function nodeNeighbors(n:Object):Array { /* Abstract */ return null; }
        
        public function distance(a:Object, b:Object):Number { /* Abstract */ return 0; }
  
        public function pointToNode(p:Point):Object { /* Abstract */ return null; }

        public function pointToVertex(p:Point):Object {
            // TODO: loop over all vertices in pointToNode and choose the closest
            return -1;
        }
    }
}
