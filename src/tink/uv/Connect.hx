package tink.uv;

import uv.Uv;
import cpp.*;
import tink.Chunk;

@:allow(tink.uv)
class Connect extends Handle {
	public var connect(default, null):uv.Connect;
	public var stream(default, null):Stream;
	
	function new(connect:uv.Connect, stream) {
		super(connect);
		this.connect = connect;
		this.stream = stream;
	}
	
	static function alloc(stream) {
		return new Connect(new uv.Connect(), stream);
	}
	
	public static function retrieve(handle:uv.Connect, release = true, ?pos:haxe.PosInfos) {
		switch Std.instance((handle.getData():Connect), Connect) {
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
		if(connect != null) {
			connect.destroy();
			cleanup();
		}
	}
	
	override function cleanup() {
		super.cleanup();
		connect = null;
	}
}