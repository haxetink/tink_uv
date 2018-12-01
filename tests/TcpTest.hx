package;

import tink.uv.*;
import tink.uv.helpers.*;
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
		switch tcp.connect({ip: '93.184.216.34', port: 80}, Cb.from(onConnect)) {
			case Success(_): // ok
			case Failure(e): asserts.fail(e);
		}
		return asserts;
	}
	
	static function onConnect(req:RawPointerOfConnect, status:Int) {
		var connect = Connect.retrieve(req);
		trace(connect.stream.write('GET / HTTP/1.1\r\nHost: example.com\r\nConnection: close\r\n\r\n', Cb.from(onWrite)));
		trace(connect.stream.readStart(Cb.from(onRead)));
		// cb(status);
	}
	
	static function onWrite(handle:RawPointerOfWrite, status:Int) {
		Write.retrieve(handle);
		trace('written ${status.toResult()}');
	}
	
	static function onRead(handle:RawPointerOfStream, nread:SSizeT, buf:RawConstPointerOfBuf) {
		var stream = Stream.retrieve(handle);
		stream.readStop();
		switch nread.toResult() {
			case Success(_):
				var buf = Buf.retrieve(buf);
				var bytes = buf.slice(nread);
				trace(bytes.length);
				stream.readStart(Cb.from(onRead));
			case Failure(e) if(e.isEof()):
				trace('ended');
				var cb:Int->Void = stream.data;
				cb(0);
			case Failure(e):
				trace(e);
				var cb:Int->Void = stream.data;
				cb(e.code);
		}
	}
}