// Miscellaneous functions for A* Demonstration
// Copyright 2007 Amit J Patel, amitp@cs.stanford.edu
// License: MIT (see LICENSE file)

package ai
{
    import flash.display.Graphics;
    import flash.geom.Point;
    
    // This class implements static helper functions, some of which
    // work on a graph
    
    public class Utils
	{
        public static var graph:Graph;

        // Given r, g, b from 0 to 1, compute a Flash color integer
        public static function makeColor(r:Number, g:Number, b:Number):int
		{
            var ri:int = Math.max(0, Math.min(255, Math.round(255.0*r)));
            var gi:int = Math.max(0, Math.min(255, Math.round(255.0*g)));
            var bi:int = Math.max(0, Math.min(255, Math.round(255.0*b)));
            return 65536*ri + 256*gi + bi;
        }
        
        // For vertices 0..n-1, compute midpoint i as halfway between
        // vertex i and i+1; return an array of midpoints.
        public static function computePolygonMidpoints(vertices:Array):Array 
		{
            var midpoints:Array = [];
            for (var i:int = 0; i != vertices.length; i++) {
                var q:Point = Point.interpolate
                    (vertices[i], vertices[(i+1)%vertices.length], 0.5);
                midpoints.push(q);
            }
            return midpoints;
        }
        
        public static function drawArrow(graphics:Graphics,
                                         p:Point, q:Point):void 
		{
            var stem_length:Number = 0.7;
            var head_length:Number = 0.4;
            var stem_width:Number = 0.05;
            var head_width:Number = 0.25;
            
            // Shorten the arrow
            // NOTE: interpolate is backwards, in that 0 means favor p2
            var s:Point = Point.interpolate(p, q, 0.8);
            var dx:Number = (q.x - p.x) * 0.6;
            var dy:Number = (q.y - p.y) * 0.6;
            
            graphics.moveTo(s.x + dx*0.05, s.y + dy*0.05);
            graphics.lineTo(s.x - dy*stem_width, s.y + dx*stem_width);
            graphics.lineTo(s.x + dx*stem_length - dy*stem_width, s.y + dy*stem_length + dx*stem_width);
            graphics.lineTo(s.x + dx*(1-head_length) - dy*head_width, s.y + dy*(1-head_length) + dx*head_width);
            graphics.lineTo(s.x + dx, s.y + dy);
            graphics.lineTo(s.x + dx*(1-head_length) + dy*head_width, s.y + dy*(1-head_length) - dx*head_width);
            graphics.lineTo(s.x + dx*stem_length + dy*stem_width, s.y + dy*stem_length - dx*stem_width);
            graphics.lineTo(s.x + dy*stem_width, s.y - dx*stem_width);
            graphics.lineTo(s.x + dx*0.05, s.y + dy*0.05);
        }

        public static function drawExploredNodes(pathfinder:Pathfinder, graphics:Graphics):void
		{
            // Draw the explored nodes, showing h/f/g as
            // R/G/B. Choose a color scale by looking for the
            // maximum h.
            var maxF:Number = 0.0;
            var minF:Number = Infinity;
            var n:String;
            for (n in pathfinder.visited) 
			{
                var info:Object = pathfinder.visited[n];
                if (!info.open)
				{
                    maxF = Math.max(maxF, info.f);
                    minF = Math.min(minF, info.f);
                }
            }
            var hScale:Number = (1-pathfinder.alpha)/Math.max(pathfinder.alpha, 1-pathfinder.alpha);
            var gScale:Number = pathfinder.alpha/Math.max(pathfinder.alpha, 1-pathfinder.alpha);
            for (n in pathfinder.visited) 
			{
                var info2:Object = pathfinder.visited[n];
                var color:int = makeColor(hScale*info2.h/maxF, info2.f/maxF, gScale*info2.g/maxF);

                /* TODO: allow coloring by f value, to show the frontier: 
                color = makeColor(0.2 + 0.5*(info2.f-minF)/(maxF-minF+1), (info2.f-minF)/(maxF-minF+1), 0.5*(info2.f-minF)/(maxF-minF+1));
                */

                /* TODO: allow coloring by openness: color = info2.open? 0x993333 : 0x339933; */
                graphics.beginFill(color, 1.0);
                graphics.lineStyle(1, 0x8c8c80, 0.8);
                drawNode(graphics, info2.node, false);
                graphics.lineStyle();
                graphics.endFill();
            }
        }

        // Draw arrows showing the parent pointers
        public static function drawParentPointers(pathfinder:Pathfinder, graphics:Graphics):void
		{
            for (var n:String in pathfinder.visited) {
                var info:Object = pathfinder.visited[n];
                if (info.parent) {
                    var a:Point = graph.nodeCenter(info.node);
                    var b:Point = graph.nodeCenter(info.parent.node);
                    graphics.beginFill(0x000000, 0.2);
                    drawArrow(graphics, b, a);
                    graphics.endFill();
                }
            }
        }

        // Draw the path found by the pathfinder. Note that the path
        // is stored in reverse order: the last element is the
        // beginning of the path.
        public static function drawPath(path:Array, graphics:Graphics):void
		{
            // NOTE: fill settings are being corrupted for some reason,
            // and filling with alpha=0 is a workaround. :(
            graphics.beginFill(0x000000, 0.0);
            graphics.lineStyle(4, 0x000000, 0.6);
            for (var k:int = 2; k < path.length; k++) {
                var a:Point = graph.nodeCenter(path[k-2]);
                var b:Point = graph.nodeCenter(path[k-1]);
                var c:Point = graph.nodeCenter(path[k]);
                // Interpolate in order to draw from edge to edge
                c = Point.interpolate(b, c, 0.5);
                a = Point.interpolate(a, b, 0.5);
                if (k == 2) graphics.moveTo(a.x, a.y);

                /*
                // Interpolate the control point to make diagonals look straight
                b = new Point(0.34*b.x + 0.33*a.x + 0.33*c.x,
                              0.34*b.y + 0.33*a.y + 0.33*c.y);
                */

                graphics.curveTo(b.x, b.y, c.x, c.y);
            }
            graphics.lineStyle();
            graphics.endFill();

            graphics.beginFill(0xffffff);
            for (k = 1; k < path.length; k++) {
                a = graph.nodeCenter(path[k-1]);
                b = graph.nodeCenter(path[k]);
                drawArrow(graphics, b, a);
            }
            graphics.endFill();
        }

        // Draw the node, either regular or a curved variant.
        public static function drawNode(graphics:Graphics, n:Object,
                                        curved:Boolean):void
		{
            var vertices:Array = graph.nodeGeom(n);
            var midpoints:Array = computePolygonMidpoints(vertices);

            var start:Point = curved? midpoints[midpoints.length-1]
                : vertices[vertices.length-1];
            
            graphics.moveTo(start.x, start.y);
            
            for (var i:int = 0; i != vertices.length; i++) {
                if (curved) {
                    graphics.curveTo(vertices[i].x, vertices[i].y,
                                     midpoints[i].x, midpoints[i].y);
                } else {
                    graphics.lineTo(vertices[i].x, vertices[i].y);
                }
            }
        }

        public static function drawGrid(graphics:Graphics, costs:Object):void
		{
            graphics.clear();
            var nodes:Array = graph.allNodes();
            for (var i:int = 0; i != nodes.length; i++) {
                var cost:Number = costs[graph.nodeToString(nodes[i])];
                if (isNaN(cost)) cost = 1; // default
                graphics.beginFill(!isFinite(cost)? 0x999988:0xe0e0d8, 1.0)
                graphics.lineStyle(0, 0x8c8c80, 0.5);
                drawNode(graphics, nodes[i], false);
                graphics.endFill();
            }
        }


        /*
        public function drawLineOnTriangularGrid(graphics:Graphics, n1:Object, n2:Object):void {
            // alternate coordinate system
            var a1:int = n1.v, b1:int = n1.u, c1:int = n1.u+n1.v+n1.w;
            var a2:int = n2.v, b2:int = n2.u, c2:int = n2.u+n2.v+n2.w;
            // distance along each axis
            var da:int = a2 - a1, db:int = b2 - b1, dc:int = c2 - c1;
            // sign
            var sa:int = (da < 0)? -1 : 1, sb:int = (db < 0)? -1 : 1, sc:int = (dc < 0)? -1 : 1;
            // let da, db, dc be nonnegative
            da = da / sa; db = db / sb; dc = dc / sc;
            // distance
            var d:int = da + db + dc;
            
            Debug.trace("LINE uvw: "+n1.u+","+n1.v+","+n1.w+" -- "+n2.u+","+n2.v+","+n2.w
              + " abc: "+a1+","+b1+","+c1+" -- "+a2+","+b2+","+c2);
            
            var pa:int = 0, pb:int = 0, pc:int = 0;
            var a:int = a1, b:int = b1, c:int = c1;
            for (var i:int = 0; i <= d; i++) {
                Debug.trace(" line "+i+" uvw: " + b+" "+a+" "+(c-b-a)+ " abc:"+a+","+b+","+c
                  + " p:"+pa+" "+pb+" "+pc);
                graphics.beginFill(0xffffcc, 1.0);
                Utils.drawNode(graphics, {u: b, v: a, w: c - b - a}, true);
                graphics.endFill();
                
                pa += da; pb += db; pc += dc;
                var ea:* = (c - b - (a+sa)); ea = (ea == 0 || ea == 1);
                var eb:* = (c - (b+sb) - a); eb = (eb == 0 || eb == 1);
                var ec:* = ((c+sc) - b - a); ec = (ec == 0 || ec == 1);
                if (ec && (pc >= pa || !ea) && (pc >= pb || !eb)) {
                    pc -= d; c += sc;
                } else if (eb && (pb >= pa || !ea)) {
                    pb -= d; b += sb;
                } else if (ea) {
                    pa -= d; a += sa;
                }
                
                if (ea > 1 || eb > 1 || ec > 1) {
                    Debug.trace("FAIL FAIL FAIL " + ea + " " + eb + " " + ec);
                }
            }
            } */
        
    }
}
