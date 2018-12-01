package tink.uv;

import uv.Uv;
import cpp.*;

class Timer extends Handle {
	public var timer(default, null):uv.Timer;
	
	var _onTimer:Void->Void;
	
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
		if(_onTimer == null) {
			var result = timer.start(Callable.fromStaticFunction(onTimer), timeout, repeat);
			if(result == 0) {
				retain();
				_onTimer = cb;
			}
			return result;
		} else {
			// TODO: align with the behaviour with libuv, do they just replace the callback?
			return Uv.EINVAL;
		}
	}
	
	public inline function stop() {
		release();
		timer.stop();
	}
	
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
	
	static function onTimer(handle:RawPointer<Timer_t>):Void {
		var timer = tink.uv.Timer.retrieve(handle, false);
		timer._onTimer();
	}
	
}