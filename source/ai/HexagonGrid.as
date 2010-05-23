// Hex grid for A* Demonstration
// Copyright 2007 Amit J Patel, amitp@cs.stanford.edu
// License: MIT (see LICENSE file)

package {
    import Graph;
    import flash.geom.Point;

    public class HexagonGrid extends Graph {
        public var size:int; // in pixels, half-width of a hexagon
        public var radius:int; // size of grid

        public function HexagonGrid(radius_:int, size_:int) {
            radius = radius_;
            size = size_;
        }
        
        override public function allNodes():Array {
            var result:Array = new Array();
            for (var u:int = 0; u <= radius*2; u++) {
                for (var v:int = 0; v <= radius*2; v++) {
                    var node:Object = { u: u, v: v };
                    if (nodeValid(node)) {
                        result.push(node);
                    }
                }
            }
            return result;
        }
        
        override public function centerNode():Object {
            return { u: radius, v: radius };
        }
        
        override public function nodeValid(n:Object):Boolean {
            return (0 <= n.u && n.u <= radius*2 && 0 <= n.v && n.v <= radius*2
                    && radius <= n.v + n.u && n.v + n.u <= 3*radius);
        }
        
        override public function nodeToString(n:Object):String {
            return "" + n.u + "," + n.v;
        }

        override public function stringToNode(s:String):Object {
            var fields:Array = s.split(",", 2);
            return {u: Number(fields[0]), v: Number(fields[1])};
        }
        
        override public function nodesEqual(n1:Object, n2:Object):Boolean {
            return (n1.u == n2.u) && (n1.v == n2.v);
        }
        
        override public function nodeNeighbors(n:Object):Array {
            var r:Array = new Array({ u: n.u, v: n.v+1 },
                                    { u: n.u+1, v: n.v },
                                    { u: n.u+1, v: n.v-1 },
                                    { u: n.u, v: n.v-1 },
                                    { u: n.u-1, v: n.v },
                                    { u: n.u-1, v: n.v+1 });
            var result:Array = new Array();
            for (var i:int = 0; i != r.length; i++) {
                if (nodeValid(r[i])) {
                    result.push(r[i]);
                }
            }
            return result;
        }
        
        override public function nodeVertices(n:Object):Array {
            return new Array({ u: n.u+1, v: n.v, w: 0 },
                             { u: n.u, v: n.v, w: 1 },
                             { u: n.u+1, v: n.v-1, w: 0 },
                             { u: n.u-1, v: n.v, w: 1 },
                             { u: n.u, v: n.v, w: 0 },
                             { u: n.u-1, v: n.v+1, w: 1 });
        }
        
        override public function vertexGeom(v:Object):Point {
            return new Point(size * (v.u * 1.5 + v.w * 2),
                             size * ((v.v + v.u*0.5)*Math.sqrt(3)));
        }
        
        override public function pointToNode(p:Point):Object {
            // TODO: u is not calculated correctly here
            var u:Number = Math.floor(p.x / 1.5 / size);
            var v:Number = Math.floor(p.y / size / Math.sqrt(3) - u*0.5 + 0.5);
            var node:Object = { u: u, v: v };
            if (nodeValid(node)) {
                return node;
            } else {
                return null;
            }
        }
        
        override public function distance(a:Object, b:Object):Number {
            return Math.max(Math.abs(a.u-b.u),
                            Math.abs(a.v-b.v),
                            Math.abs((a.u+a.v)-(b.u+b.v)));
        }
    }
}
