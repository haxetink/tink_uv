package tink.uv;

import uv.Uv;
import cpp.*;

using tink.uv.Result;
using tink.CoreApi;

class Tcp extends Stream {
	public var tcp(default, null):uv.Tcp;
	
	function new(tcp:uv.Tcp) {
		super(tcp);
		this.tcp = tcp;
	}
	
	public static function alloc(?loop:uv.Loop) {
		var handle = new uv.Tcp();
		handle.init(loop == null ? uv.Loop.DEFAULT : loop);
		return new Tcp(handle);
	}
	
	public static function retrieve(handle:uv.Tcp, ?pos:haxe.PosInfos) {
		switch Std.instance((handle.getData():Tcp), Tcp) {
			case null: throw 'No wrapper instance is stored in this handle';
			case v: return v;
		}
	}
	
	public function connect(dest, cb:Int->Void, ?pos:haxe.PosInfos) {
		var req = Connect.alloc(this);
		var addr = new uv.SockAddrIn();
		addr.ip4Addr(dest.ip, dest.port);
		var result = tcp.connect(req.connect, addr, Callable.fromStaticFunction(onConnect));
		if(result == 0) {
			retain(pos);
			req.retain(pos);
			req.data = cb;
		}
		addr.destroy(); 
		return result;
	}
	
	public function bind(target, flags) {
		var addr = new uv.SockAddrIn();
		addr.ip4Addr(target.ip, target.port);
		var result = tcp.bind(addr, flags);
		addr.destroy();
		return result;
	}
	
	override function finalize() {
		if(tcp != null) {
			tcp.destroy();
			cleanup();
		}
	}
	
	override function cleanup() {
		super.cleanup();
		tcp = null;
	}
	
	static function onConnect(req:RawPointer<Connect_t>, status:Int) {
		var connect = Connect.retrieve(req);
		var cb:Int->Void = connect.data;
		cb(status);
	}
}