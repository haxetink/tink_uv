package tink.uv;

import uv.Uv;
import cpp.*;
import tink.Chunk;

@:allow(tink.uv)
class Shutdown extends Req {
	public var shutdown(default, null):uv.Shutdown;
	public var stream(default, null):Stream;
	
	function new(shutdown:uv.Shutdown, stream) {
		super(shutdown);
		this.shutdown = shutdown;
		this.stream = stream;
	}
	
	static function alloc(stream) {
		return new Shutdown(new uv.Shutdown(), stream);
	}
	
	public static function retrieve(handle:uv.Shutdown, release = true, ?pos:haxe.PosInfos) {
		switch Std.instance((handle.getData():Shutdown), Shutdown) {
			case null: throw 'No wrapper instance is stored in this handle';
			case v: 
				trace(Stream.retrieve(handle.handle, false) == v.stream);
				if(release) {
					v.release(pos);
					v.stream.release(pos);
				}
				return v;
		}
	}
	
	override function finalize() {
		if(shutdown != null) {
			shutdown.destroy();
			cleanup();
		}
	}
	
	override function cleanup() {
		super.cleanup();
		shutdown = null;
	}
}