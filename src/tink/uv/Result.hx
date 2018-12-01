package tink.uv;

using tink.CoreApi;

class Result {
	static var SUCCESS = Success(Noise);
	
	public static function toResult(status:Int):Outcome<Noise, UvError> {
		return status >= 0 ? SUCCESS : Failure((status:UvError));
	}
}