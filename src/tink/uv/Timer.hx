package tink.uv;

import uv.Uv;
import cpp.*;
import tink.Chunk;
import tink.uv.helpers.*;
import haxe.io.Bytes;

using tink.uv.Result;

class Timer extends Handle {
	public var timer(default, null):uv.Timer;
	
	function new(timer:uv.Timer) {
		super(timer);
		this.timer = timer;
	}
	
	
	public static function alloc(?loop:uv.Loop) {
		var handle = new uv.Timer();
		handle.init(loop == null ? uv.Loop.DEFAULT : loop);
		return new Timer(handle);
	}
	
	public static function retrieve(handle:uv.Timer, release = true, ?pos:haxe.PosInfos) {
		switch Std.instance((handle.getData():Timer), Timer) {
			case null: throw 'No wrapper instance is stored in this handle';
			case v: 
				if(release) v.release(pos);
				return v;
		}
	}
	
	
	public inline function start(cb, timeout, repeat) {
		retain();
		timer.start(cb, timeout, repeat);
	}
	
	public inline function stop() timer.stop();
	
	override function finalize() {
		if(timer != null) {
			timer.destroy();
			cleanup();
		}
	}
	
	override function cleanup() {
		super.cleanup();
		timer = null;
	}
	
	static function onAlloc(handle:RawPointerOfHandle, size:SizeT, buf:RawPointerOfBuf) {
		Buf.alloc(Bytes.alloc(cast size), buf);
	}
}