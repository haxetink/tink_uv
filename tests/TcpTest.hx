package;

import tink.uv.*;
import tink.unit.AssertionBuffer as Asserts;
import cpp.*;
import uv.Uv;

using tink.uv.Result;

@:asserts
class TcpTest {
	public function new() {}
	
	public function client() {
		var tcp = Tcp.alloc();
		tcp.data = function(status) {
			asserts.assert(status == 0);
			asserts.done();
		}
		switch tcp.connect({ip: '93.184.216.34', port: 80}, cpp.Callable.fromStaticFunction(onConnect)) {
			case Success(_): // ok
			case Failure(e): asserts.fail(e);
		}
		return asserts;
	}
	
	static function onConnect(req:RawPointerOfConnect, status:Int) {
		var connect = Connect.retrieve(req);
		trace(connect.stream.write('GET / HTTP/1.1\r\nHost: example.com\r\nConnection: close\r\n\r\n', Callable.fromStaticFunction(onWrite)));
		trace(connect.stream.readStart(Callable.fromStaticFunction(onRead)));
		// cb(status);
	}
	
	static function onWrite(handle:RawPointer<Write_t>, status:Int) {
		Write.retrieve(handle);
		trace('written ${status.toResult()}');
	}
	
	static function onRead(handle:RawPointer<Stream_t>, nread:SSize_t, buf:RawConstPointer<Buf_t>) {
		var nread:Int = cast nread;
		var stream = Stream.retrieve(handle);
		stream.readStop();
		switch nread.toResult() {
			case Success(_):
				var buf = Buf.retrieve(buf);
				var bytes = buf.slice(cast nread);
				trace(bytes.length);
				stream.readStart(Callable.fromStaticFunction(onRead));
			case Failure(e) if(e.isEof()):
				trace('ended');
				var cb:Int->Void = stream.data;
				cb(0);
			case Failure(e):
				trace(e);
		}
	}
}