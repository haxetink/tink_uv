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
		var result = tcp.connect({ip: '93.184.216.34', port: 80}, function(status) {
			asserts.assert(status == 0);
			trace(tcp.write(Bytes.ofString('GET / HTTP/1.1\r\nHost: example.com\r\nConnection: close\r\n\r\n'), function(i) trace('written $i')));
			trace(tcp.readStart(function(status, bytes) {
				trace(status, bytes == null ? null : bytes.length);
				if(status == Uv.EOF) asserts.done();
			}));
		});
		
		if(result != 0) asserts.fail(result, Uv.err_name(result).toString());
		return asserts;
	}
}