package tink.uv;

#if macro
import haxe.macro.Context;

class Boot {
  static function boot() {
    if(!Context.defined('tink_uv_no_run_loop'))
      tink.SyntaxHub.transformMain.whenever(function (e) { 
        return macro @:pos(e.pos) {
          $e;
          hxuv.Loop.DEFAULT.run(DEFAULT);
        }
      });
  }
}
#else 
  #error
#end
