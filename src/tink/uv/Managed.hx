package tink.uv;

#if !macro

@:genericBuild(tink.uv.Managed.build())
class Managed<T> {}

class Base extends Finalizable {
	public var data:Dynamic;
}

#else

import tink.macro.BuildCache;
import haxe.macro.Expr;

using tink.MacroApi;

class Managed {
	public static function build() {
		return BuildCache.getType('tink.uv.Managed', function(ctx:BuildContext) {
			switch ctx.type.getID().split('.') {
				case ['uv', _]: 
				case _: throw 'tink.uv.Managed only supports types in the uv.* package';
			}
			var name = ctx.name;
			var pos = ctx.pos;
			var wrapperCt = TPath(name.asTypePath());
			var handleCt = ctx.type.toComplex();
			var handleTp = ctx.type.getID().asTypePath();
			
			var def = macro class $name extends tink.uv.Managed.Base {
				static var retained:Map<$wrapperCt, Int> = new Map();
				
				var handle:$handleCt;
				
				public function new() {
					super();
					handle = new $handleTp();
				}
				
				public static function reconstruct(handle:$handleCt):$wrapperCt {
					switch Std.instance((handle.getData():$wrapperCt), $i{name}) {
						case null: throw 'The Managed instance is not stored in this handle';
						case v: return v;
					}
				}
				
				public function retain() {
					retained.set(this, switch retained.get(this) {
						case null: 1;
						case v: v + 1;
					});
				}
				
				public function release() {
					switch retained.get(this) {
						case null: // do nothing
						case 0 | 1: retained.remove(this);
						case v: retained.set(this, v - 1);
					}
				}
				
				inline function destroy() {
					finalize();
				}
				
				override function finalize() {
					if(handle != null) {
						handle.destroy();
						handle = null;
					}
				}
			}
			
			def.pack = ['tink', 'uv'];
			def.pos = ctx.pos;
			
			return def;
		});
	}
}

#end