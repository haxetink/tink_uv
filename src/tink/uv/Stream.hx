package tink.uv;

import uv.Uv;
import cpp.*;
import haxe.io.Bytes;

class Stream extends Handle {
	public var stream(default, null):uv.Stream;
	
	var _onRead:Int->Bytes->Void;
	var _onConnection:Stream->Void;
	
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
	
	// public function shutdown(cb, ?pos:haxe.PosInfos) {
	// 	var req = Shutdown.alloc(this);
	// 	var result = stream.shutdown(req.shutdown, cb);
		
	// 	if(result == 0 && cb != null) {
	// 		retain(pos);
	// 		req.retain(pos);
	// 	}
	// 	return result.toResult();
	// }
	
	public function listen(backlog, cb, ?pos:haxe.PosInfos) {
		return if(_onConnection == null) {
			var result = stream.listen(backlog, Callable.fromStaticFunction(onConnection));
			if(result == 0 && cb != null) {
				_onConnection = cb;
				retain(pos);
			}
			return result;
		} else {
			// TODO: align with the behaviour with libuv, do they just replace the callback?
			return Uv.EINVAL;
		}
	}
	
	public inline function accept(client)
		return stream.accept(client);
		
	public function readStart(cb, ?pos:haxe.PosInfos) {
		if(_onRead == null) {
			var result = stream.readStart(Callable.fromStaticFunction(onAlloc), Callable.fromStaticFunction(onRead));
			if(result == 0) {
				_onRead = cb;
				retain(pos);
			}
			return result;
		} else {
			// TODO: align with the behaviour with libuv, do they just replace the callback?
			return Uv.EINVAL;
		}
	}
	
	public function readStop() {
		if(_onRead != null) {
			release();
			_onRead = null;
		}
		return stream.readStop();
	}
	
	public function write(bytes:Bytes, cb:Int->Void, ?pos:haxe.PosInfos) {
		var buf = new uv.Buf();
		buf.alloc(bytes.length);
		buf.copyFromBytes(bytes, bytes.length);
		var req = Write.alloc(this, buf);
		req.data = cb;
		var result = stream.write(req.write, buf, 1, Callable.fromStaticFunction(onWrite));
		if(result == 0) {
			retain(pos);
			req.retain(pos);
		}
		return result;
	}
		
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
	
	function createClient():Stream {
		throw 'abstract';
	}
	
	override function cleanup() {
		super.cleanup();
		stream = null;
	}
	
	// static function onShutdown(req:RawPointer<Shutdown_t>, status:Int) {
		
	// }
	
	static function onConnection(stream:RawPointer<Stream_t>, status:Int) {
		var stream = Stream.retrieve(stream, false);
		var client = stream.createClient();
		stream._onConnection(client);
	}
	
	static function onAlloc(handle:RawPointer<Handle_t>, size:SizeT, buf:RawPointer<Buf_t>) {
		uv.Buf.fromRaw(buf).alloc(size);
	}
	
	static function onRead(handle:RawPointer<Stream_t>, nread:SSizeT, buf:RawConstPointer<Buf_t>) {
		var stream = Stream.retrieve(handle, false);
		var buf = uv.Buf.unmanaged(buf);
		var nread:Int = nread;
		if(nread > 0) {
			var bytes = Bytes.alloc(nread);
			buf.copyToBytes(bytes, nread);
			stream._onRead(nread, bytes);
		} else {
			stream.release();
			stream._onRead(nread, null);
			stream._onRead = null;
		}
		buf.free();
	}
	
	static function onWrite(handle:RawPointer<Write_t>, status:Int) {
		var write = Write.retrieve(handle);
		var cb:Int->Void = write.data;
		cb(status);
	}
}