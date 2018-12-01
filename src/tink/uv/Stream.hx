package tink.uv;

import uv.Uv;
import cpp.*;
import tink.Chunk;
import tink.uv.helpers.*;
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
	
	public function shutdown(cb, ?pos:haxe.PosInfos) {
		var req = Shutdown.alloc(this);
		retain(pos);
		req.retain(pos);
		return stream.shutdown(req.shutdown, cb).toResult();
	}
	
	public function listen(backlog, cb, ?pos:haxe.PosInfos) {
		retain(pos);
		return stream.listen(backlog, cb).toResult();
	}
	
	public inline function accept(client)
		return stream.accept(client).toResult();
		
	public function readStart(cb, ?pos:haxe.PosInfos) {
		retain(pos);
		return stream.readStart(Callable.fromStaticFunction(onAlloc), cb).toResult();
	}
	
	public function write(chunk:Chunk, cb, ?pos:haxe.PosInfos) {
		var buf = Buf.alloc(chunk);
		var req = Write.alloc(this, buf);
		retain(pos);
		buf.retain(pos);
		req.retain(pos);
		return stream.write(req.write, buf.handle, 1, cb).toResult();
	}
	
	public inline function readStop()
		return stream.readStop().toResult();
		
	public inline function isWritable()
		return stream.isWritable();
		
	public inline function isReadable()
		return stream.isReadable();
	
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
	
	static function onAlloc(handle:RawPointerOfHandle, size:SizeT, buf:RawPointerOfBuf) {
		Buf.alloc(Bytes.alloc(cast size), buf);
	}
}