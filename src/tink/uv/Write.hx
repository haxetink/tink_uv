package tink.uv;

import uv.Uv;
import cpp.*;
import tink.Chunk;

@:allow(tink.uv)
class Write extends Req {
	public var write(default, null):uv.Write;
	public var stream(default, null):Stream;
	public var buf(default, null):Buf;
	
	function new(write:uv.Write, stream, buf) {
		super(write);
		this.write = write;
		this.stream = stream;
		this.buf = buf;
	}
	
	static function alloc(stream, buf) {
		return new Write(new uv.Write(), stream, buf);
	}
	
	public static function retrieve(handle:uv.Write, release = true, ?pos:haxe.PosInfos) {
		switch Std.instance((handle.getData():Write), Write) {
			case null: throw 'No wrapper instance is stored in this handle';
			case v: 
				if(release) {
					v.release(pos);
					v.stream.release(pos);
					v.buf.release(pos);
				}
				return v;
		}
	}
	
	override function finalize() {
		if(write != null) {
			write.destroy();
			cleanup();
		}
	}
	
	override function cleanup() {
		super.cleanup();
		write = null;
	}
}