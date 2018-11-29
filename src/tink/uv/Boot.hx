package tink.uv;

#if macro
class Boot {
  static function boot() {
    tink.SyntaxHub.transformMain.whenever(function (e) { 
      return macro @:pos(e.pos) {
        $e;
        uv.Uv.run(uv.Uv.default_loop(), uv.Uv.RUN_DEFAULT);
      }
    });
  }
}
#else 
  #error
#end
