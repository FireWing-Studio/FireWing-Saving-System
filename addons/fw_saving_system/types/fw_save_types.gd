
class_name FWSaveTypes
extends RefCounted

enum Error {
	OK = 2000
}

enum Encoding {
	INVALID = 0,

	BINARY = 1,
	BINARY_ZSTD = 2
}

enum HeaderFlags {
	NONE = 0
}

class Result extends RefCounted:
	var value: Variant
	var error: Error
	
	func _init(val, err):
		value = val
		error = err
	
	func is_ok() -> bool:
		return error == null || error == Error.OK

	static func success(val: Variant) -> Result:
		return Result.new(val, null)

	static func failure(err: Error) -> Result:
		return Result.new(null, err)

class Header extends RefCounted:
	var magic_number: StringName
	var version: int
	var toc_count: int
	var flags: HeaderFlags

	var game_literal: StringName
	var game_version: StringName
	var godot_version: StringName

	var toc_checksum: PackedByteArray
	var header_checksum: PackedByteArray

class TocEntry extends RefCounted:
	var key: StringName

	var payload_offset: int
	var payload_disk_size: int
	var payload_uncompressed_size: int
	
	var payload_checksum: PackedByteArray

class FileData extends RefCounted:
	var header: Header
	var toc: Dictionary[StringName, TocEntry]
	var payloads: Array[PackedByteArray]
