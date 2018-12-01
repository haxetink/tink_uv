package tink.uv;

class Base extends cpp.Finalizable {
	static var retained:Map<Base, Int> = new Map();
	
	public var data:Any;
	
	var id:Int;
	static var ids:Int;
	
	public function new() {
		super();
		id = ids++;
	}
	
	public function retain(?pos:haxe.PosInfos) {
		var count = switch retained.get(this) {
			case null: 1;
			case v: v + 1;
		}
		retained.set(this, count);
		haxe.Log.trace('Retained ${toString()}, current reference count = $count', pos);
	}
	
	public function release(?pos:haxe.PosInfos) {
		var count = 0;
		switch retained.get(this) {
			case null: // do nothing
			case 0 | 1: retained.remove(this);
			case v: retained.set(this, count = v - 1);
		}
		haxe.Log.trace('Released ${toString()}, current reference count = $count', pos);
	}
	
	inline function destroy() {
		finalize();
	}
	
	function cleanup() {}
	
	public function toString() {
		return Type.getClassName(Type.getClass(this)).split('.').pop() + '#$id';
	}
}