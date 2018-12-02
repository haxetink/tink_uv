package tink.uv;

import tink.core.Outcome;
import tink.core.Noise;

class Result {
	public static function toResult(status:Int)
		return status == 0 ? Success(Noise) : Failure(Error.ofStatus(status));
}