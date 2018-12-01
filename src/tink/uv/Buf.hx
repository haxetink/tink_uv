package tink.uv;

import cpp.*;
import haxe.io.Bytes;

using cpp.NativeArray;

class Buf extends Base {
	
	static var references:PointerMap<Buf> = new PointerMap();
	
	public var handle(default, null):uv.Buf;
	var bytes(default, null):Bytes;
	
	public function new(bytes, handle) {
		super();
		this.bytes = bytes;
		this.handle = handle;
	}
	
	public static function alloc(bytes:Bytes, ?handle:uv.Buf) {
		if(handle == null) handle = new uv.Buf();
		var base = bytes.getData().address(0);
		handle.value.base = untyped __cpp__('(char*){0}', base.raw);
		handle.value.len = bytes.length;
		var buf = new Buf(bytes, handle);
		references.set(Pointer.fromRaw(handle.value.base), buf);
		return buf;
	}
	
	public static function retrieve(handle:uv.Buf, ?pos:haxe.PosInfos) {
		switch references.get(Pointer.fromRaw(handle.value.base)) {
			case null: throw 'No wrapper instance is stored in this handle';
			case v: return v;
		}
	}
	
	public inline function slice(size:Int) {
		return bytes.sub(0, size);
	}
	
	override function finalize() {
		if(handle != null) {
			handle.destroy();
			handle = null;
		}
	}
}

class PointerMap<T> extends haxe.ds.BalancedTree<Pointer<Char>, T> {
	override function compare(p1:Pointer<Char>, p2:Pointer<Char>) {
		return p1 == p2 ? 0 : p1.gt(p2) ? 1 : -1;
	}
}