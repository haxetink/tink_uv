package haxe;

import uv.Uv;
import cpp.*;
import cpp.vm.*;


// patch Timer so that MainLoop is not generated
class Timer {
  
  var handle:uv.Timer;
  
  public function new(time_ms:Int) {
    handle = new uv.Timer();
    handle.init(uv.Loop.DEFAULT);
    handle.start(Callable.fromStaticFunction(callback), cast time_ms, cast time_ms);
    handle.setData(this);
    Gc.setFinalizer(this, Callable.fromStaticFunction(finalize));
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
    return (cast Uv.hrtime()) / 1e9;
  }
  
  static function callback(handle:RawPointer<Timer_t>):Void {
    var timer:Timer = uv.Timer.fromRaw(handle).getData();
    timer.run();
  }
  
  static function finalize(timer:Timer) {
    if(timer.handle != null) {
      timer.handle.destroy();
      timer.handle = null;
    }
  }
}