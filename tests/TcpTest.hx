package;

import tink.uv.*;
import tink.uv.helpers.*;
import tink.unit.AssertionBuffer as Asserts;
import cpp.*;
import haxe.io.Bytes;
import uv.Uv;

@:asserts
class TcpTest {
	public function new() {}
	
	public function client() {
		var tcp = Tcp.alloc();
		var r = tcp.connect({ip: '93.184.216.34', port: 80}, function(status) {
			asserts.assert(status == 0);
			var r = tcp.write(Bytes.ofString('GET / HTTP/1.1\r\nHost: example.com\r\nConnection: close\r\n\r\n'), function(status) asserts.assert(status == 0));
			asserts.assert(r == 0);
			var r = tcp.readStart(function(status, bytes) {
				if(status > 0) {
					asserts.assert(bytes.length == status);
				} else if(status == Uv.EOF) {
					asserts.assert(bytes == null);
					asserts.done();
				} else {
					asserts.assert(bytes == null);
					asserts.fail(status, Uv.err_name(status).toString());
				}
			});
			asserts.assert(r == 0);
		});
		
		asserts.assert(r == 0);
		return asserts;
	}
}