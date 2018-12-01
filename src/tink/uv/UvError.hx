package tink.uv;

import uv.Uv;

using tink.CoreApi;

abstract UvError(Error) to Error #if tink_unittest to tink.unit.AssertionBuffer.FailingReason #end{
	inline function new(e) this = e;
	@:from public static inline function fromStatus(code:Int):UvError {
		return new UvError(new Error(code, uv.Uv.err_name(code)));
	}
	
	public inline function isEof() {
		return this.code == Uv.EOF;
	}
}