package tink.uv;

abstract Error(tink.core.Error) from tink.core.Error to tink.core.Error {
	@:from
	public static function ofStatus(status:Int):Error
		return new tink.core.Error(status, hxuv.ErrorCode.getName(status));
}