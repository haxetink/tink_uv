package tink.uv.helpers;

class Cb {
	public static inline function from<T>(v:T)
		return cpp.Callable.fromStaticFunction(v);
}