// Triangle grid for A* Demonstration
// Copyright 2007 Amit J Patel, amitp@cs.stanford.edu
// License: MIT (see LICENSE file)

package {
    import Graph;
    import flash.geom.Point;
    
    public class TriangleGrid extends Graph {
        public var size:int; // width of triangle, in pixels
        public var radius:int; // size of grid

        public function TriangleGrid(radius_:int, size_:int) {
            radius = radius_;
            size = size_;
        }
        
        override public function allNodes():Array {
            var result:Array = new Array();
            for (var u:int = 0; u <= radius*2; u++) {
                for (var v:int = 0; v <= radius*2; v++) {
                    for (var w:int = 0; w != 2; w++) {
                        var node:Object = {u: u, v: v, w: w};
                        if (nodeValid(node)) {
                            result.push(node);
                        }
                    }
                }
            }
            return result;
        }
        
        override public function centerNode():Object {
            return { u: radius, v: radius, w: 0 };
        }
        
        override public function nodeValid(n:Object):Boolean {
            return (0 <= n.u && n.u <= radius*2
                    && 0 <= n.v && n.v <= radius*2
                    && radius <= n.u+n.v+n.w && n.u+n.v+n.w <= radius*3
                    && 0 <= n.w && n.w < 2);
        }
        
        override public function nodeToString(n:Object):String {
            return ""+n.u+","+n.v+","+n.w;
        }

        override public function stringToNode(s:String):Object {
            var fields:Array = s.split(",", 3);
            return {u: Number(fields[0]), v: Number(fields[1]), w: Number(fields[2])};
        }
        
        override public function nodesEqual(n1:Object, n2:Object):Boolean {
            return (n1.u == n2.u) && (n1.v == n2.v) && (n1.w == n2.w);
        }
        
        override public function nodeVertices(n:Object):Array {
            if (n.w != 0) {
                return new Array({ u: n.u+1, v: n.v+1 },
                                 { u: n.u+1, v: n.v },
                                 { u: n.u, v: n.v+1 });
            } else {
                return new Array({ u: n.u, v: n.v+1 },
                                 { u: n.u+1, v: n.v },
                                 { u: n.u, v: n.v });
            }
        }
        
        override public function vertexGeom(v:Object):Point {
            return new Point(size * (v.u + v.v/2),
                             size * (v.v * Math.sqrt(3)/2));
        }
        
        override public function pointToNode(p:Point):Object {
            var v:Number = p.y / size / (Math.sqrt(3)/2);
            var u:Number = p.x / size - v/2;
            var w:Number = ((u - Math.floor(u)) + (v - Math.floor(v))) >= 1.0 ? 1 : 0;
            var node: Object = {u: Math.floor(u), v: Math.floor(v), w: w};
            if (nodeValid(node)) {
                return node;
            } else {
                return null;
            }
        }
        
        override public function nodeNeighbors(n:Object):Array {
            var r:Array = new Array();
            if (n.w) {
                r.push({u: n.u, v: n.v+1, w: 0});
                r.push({u: n.u+1, v: n.v, w: 0});
                r.push({u: n.u, v: n.v, w: 0});
            } else {
                r.push({u: n.u, v: n.v, w: 1});
                r.push({u: n.u, v: n.v-1, w: 1});
                r.push({u: n.u-1, v: n.v, w: 1});
            }
            
            var result:Array = new Array();
            for (var i:int = 0; i != r.length; i++) {
                if (nodeValid(r[i])) {
                    result.push(r[i]);
                }
            }
            return result;
        }
        
        override public function distance(a:Object, b:Object):Number {
            return Math.abs(a.u-b.u) + Math.abs(a.v-b.v)
                + Math.abs((a.u+a.v+a.w)-(b.u+b.v+b.w));
        }
    }
}
