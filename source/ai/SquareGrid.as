// Square grid for A* Demonstration
// Copyright 2007 Amit J Patel, amitp@cs.stanford.edu
// License: MIT (see LICENSE file)

package {
    import Graph;
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
        
        override public function allNodes():Array {
            var result:Array = new Array();
            for (var u:int = 0; u != width; u++) {
                for (var v:int = 0; v != height; v++) {
                    result.push({ u: u, v: v });
                }
            }
            return result;
        }
        
        override public function centerNode():Object {
            return { u: Math.floor(width/2), v: Math.floor(height/2) };
        }

        override public function nodeToString(n:Object):String {
            return ""+n.u+","+n.v;
        }
        
        override public function stringToNode(s:String):Object {
            var fields:Array = s.split(",", 2);
            return {u: Number(fields[0]), v: Number(fields[1])};
        }
        
        override public function nodesEqual(n1:Object, n2:Object):Boolean {
            return (n1.u == n2.u) && (n1.v == n2.v);
        }
        
        override public function nodeVertices(n:Object):Array {
            return new Array({ u: n.u, v: n.v },
                             { u: n.u+1, v: n.v },
                             { u: n.u+1, v: n.v+1 },
                             { u: n.u, v: n.v+1 });
        }
        
        override public function vertexGeom(v:Object):Point {
            return new Point(v.u * size, v.v * size);
        }
        
        override public function nodeValid(n:Object):Boolean {
            return (0 <= n.u && n.u < width && 0 <= n.v && n.v < height);
        }
        
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

        override public function distance(a:Object, b:Object):Number {
            return Math.abs(a.u - b.u) + Math.abs(a.v - b.v);
        }
    }
}
