// Flash debugging widget
// Copyright 2007 Amit J Patel, amitp@cs.stanford.edu
// License: MIT (see LICENSE file)

package {
  // Used for debugging output

  import flash.display.Sprite;

  import flash.external.ExternalInterface;
  import flash.text.*;
  
  public class Debug extends Sprite {
    
    CONFIG::debugging {
      private var txt:TextField;
      private var lines:Array;
      private static var singleton:Debug;
    }
    
    public function Debug(parent:Sprite) {
      CONFIG::debugging {
        // There can be only one!!
        if (singleton) {
          // TODO: throw an error?
        }
        singleton = this;
        
        cacheAsBitmap = true;
        mouseEnabled = false;
        mouseChildren = false;
        
        txt = new TextField();
        txt.selectable = false;
        var format:TextFormat = txt.getTextFormat();
        format.color = 0x330000;
        format.font = "_typewriter";
        format.size = 7;
        txt.defaultTextFormat = format;
        txt.autoSize = TextFieldAutoSize.LEFT;
        addChild(txt);
        
        lines = [];
      }
    }
    
    public static function trace(...args):void {
      CONFIG::debugging {
        for (var i:int = 0; i < args.length; i++) {
          if (typeof args[i] == "number") {
            args[i] = formatNumber(args[i]);
          }
        }
        singleton.lines.push(args.join(" "));
        singleton.txt.appendText("\n" + args.join(" "));
        
        /*
          if (ExternalInterface.available) {
          ExternalInterface.call.apply(null, ["console.log"].concat(args));
          }
        */
        
        while (singleton.txt.height > singleton.stage.stageHeight /2 && singleton.lines.length > 0) {
          singleton.lines.shift();
          singleton.txt.text = singleton.lines.join("\n");
        }
      }
    }
      
    public static function formatNumber(x:Number):String {
      return x.toFixed((x == Math.round(x))? 0 : 1);
    }
  }
}
