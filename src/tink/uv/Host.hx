package tink.uv;

import uv.*;
import uv.Uv;
import cpp.*;

using tink.CoreApi;
using cpp.NativeString;


// TODO: use tink_ip
enum IpVersion {
	V4;
	V6;
}

class Host {
	public static function resolve(host:String, version:IpVersion):Promise<String> {
		var trigger = Future.trigger();
		
		var ip = 0;
		
		switch Uv.inet_pton(version == V4 ? Uv.AF_INET : Uv.AF_INET6, host, cast RawPointer.addressOf(ip)) {
			case 0:
				trigger.trigger(Success(host));
			case _:
				var hint = new AddrInfo();
				var resolver = new GetAddrInfo();
				resolver.setData(trigger);
				switch resolver.get(Uv.default_loop(), Callable.fromStaticFunction(onResolve), host, '80', hint) {
					case 0: // ok, just wait for the cb
					case code: trigger.trigger(Failure(new Error(Uv.err_name(code))));
				}
		}
		return trigger;
	}
	
	static function onResolve(resolver:RawPointer<GetAddrInfo_t>, status:Int, res:RawPointer<AddrInfo_s>) {
		var resolver:GetAddrInfo = resolver;
		var trigger:FutureTrigger<Outcome<String, Error>> = resolver.getData();
		var addr = AddrInfo.fromRaw(res);
		if(status != 0) {
			trigger.trigger(Failure(new Error(Uv.err_name(status))));
		} else {
			untyped __cpp__("char ret[17] = {'\\0'}");
			switch Uv.ip4_name(addr, untyped __cpp__('ret'), cast 16) {
				case 0:
					trigger.trigger(Success(untyped __cpp__('::String(ret)')));
				case code:
					trigger.trigger(Failure(new Error(Uv.err_name(code))));
			}
		}
		
		addr.destroy();
	}
}