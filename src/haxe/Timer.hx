package haxe;

import uv.Uv;
import cpp.*;
import cpp.vm.*;
import tink.uv.helpers.*;

// patch Timer so that MainLoop is not generated
class Timer {
  
  var handle:tink.uv.Timer;
  
  public function new(time_ms:Int) {
    handle = tink.uv.Timer.alloc();
    handle.start(function() run(), time_ms, time_ms); // wrap run because it is dynamic
  }
  
  dynamic public function run() {}
  
  public function stop() {
    handle.stop();
    handle.destroy();
    handle = null;
  }
  
  public static function delay(f:Void->Void, time_ms:Int):Timer {
    var t = new haxe.Timer(time_ms);
    t.run = function() {
      t.stop();
      f();
    };
    return t;
  }
  
  public static function measure<T>(f:Void->T, ?pos:haxe.PosInfos):T {
    var t0 = stamp();
    var r = f();
    haxe.Log.trace((stamp() - t0) + "s", pos);
    return r;
  }
  
  public static function stamp():Float {
    return Uv.hrtime() / 1e9;
  }
}