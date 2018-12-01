package tink.uv;

import uv.Uv;
import cpp.*;
import tink.Chunk;
import haxe.io.Bytes;

using tink.uv.Result;

class Stream extends Handle {
	public var stream(default, null):uv.Stream;
	
	function new(stream:uv.Stream) {
		super(stream);
		this.stream = stream;
	}
	
	public static function alloc() {
		return new Stream(new uv.Stream());
	}
	
	public static function retrieve(handle:uv.Stream, release = true, ?pos:haxe.PosInfos) {
		switch Std.instance((handle.getData():Stream), Stream) {
			case null: throw 'No wrapper instance is stored in this handle';
			case v: 
				if(release) v.release(pos);
				return v;
		}
	}
	
	
	public function shutdown(req, cb, ?pos:haxe.PosInfos) {
		retain(pos);
		return shutdown(req, cb);
	}
	public function listen(backlog, cb, ?pos:haxe.PosInfos) {
		retain(pos);
		return listen(backlog, cb);
	}
	public inline function accept(client) return accept(client);
	public function readStart(cb, ?pos:haxe.PosInfos) {
		retain(pos);
		return stream.readStart(Callable.fromStaticFunction(onAlloc), cb).toResult();
	}
	public inline function write(chunk:Chunk, cb, ?pos:haxe.PosInfos) {
		var buf = Buf.alloc(chunk);
		var req = Write.alloc(this, buf);
		retain(pos);
		buf.retain(pos);
		req.retain(pos);
		return stream.write(req.write, buf.handle, 1, cb).toResult();
	}
	public inline function readStop() return readStop();
	public inline function isWritable() return isWritable();
	public inline function isReadable() return isReadable();
	
	override function finalize() {
		if(stream != null) {
			stream.destroy();
			cleanup();
		}
	}
	
	override function cleanup() {
		super.cleanup();
		stream = null;
	}
	
	static function onAlloc(handle:RawPointer<Handle_t>, size:Size_t, buf:RawPointer<Buf_t>) {
		Buf.alloc(Bytes.alloc(cast size), buf);
	}
}