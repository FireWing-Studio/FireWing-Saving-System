
class_name FWBinaryParser
extends RefCounted

const MAGIC_NUMBER: int = 0x56535746	# FWSV

const GAME_LITERAL_SIZE = 32
const GAME_VERSION_SIZE = 32
const GODOT_VERSION_SIZE = 32

var game_literal: PackedByteArray
var game_version: PackedByteArray
var godot_version: PackedByteArray

func _init(game_lit: StringName, game_vers: StringName, godot_vers: StringName):
	game_literal = _adapt_string_to_buf(game_lit, GAME_LITERAL_SIZE)
	game_version = _adapt_string_to_buf(game_vers, GAME_VERSION_SIZE)
	godot_version = _adapt_string_to_buf(godot_vers, GODOT_VERSION_SIZE)

func _adapt_string_to_buf(str: StringName, size: int) -> PackedByteArray:
	var buf: PackedByteArray = str.to_ascii_buffer()
	if buf.size() >= size:
		buf = buf.slice(0, size-1)
	buf.resize(size)

	return buf

func decode(bytes: PackedByteArray) -> FWSaveTypes.Result:
	var file_data := FWSaveTypes.FileData.new()
	var stream := StreamPeerBuffer.new()
	stream.big_endian = false
	stream.data_array = bytes

	if stream.get_size() < 8:
		return FWSaveTypes.Result.failure(FWSaveTypes.Error.FILE_SIZE_TOO_SMALL)
	
	var magic_number := stream.get_u32()
	if magic_number != MAGIC_NUMBER:
		return FWSaveTypes.Result.failure(FWSaveTypes.Error.INVALID_FILE_TYPE)
	
	var header_version := stream.get_u32()
	file_data.header.version = header_version
	match header_version:
		1:
			return _decode_v1(stream, file_data)
		_:
			return FWSaveTypes.Result.failure(FWSaveTypes.Error.UNKNOWN_HEADER_VERSION)

func _decode_v1(stream: StreamPeerBuffer, file_data: FWSaveTypes.FileData) -> FWSaveTypes.Result:
	if stream.get_size() < 256:
		return FWSaveTypes.Result.failure(FWSaveTypes.Error.FILE_SIZE_TOO_SMALL)
	
	var file_size = stream.get_u32()
	file_data.header.file_size = file_size
	
	var toc_count = stream.get_u16()
	file_data.header.toc_count = toc_count
	
	var flags = stream.get_u16()
	file_data.header.flags = flags
	
	var game_literal = stream.get_string(32)
	file_data.header.game_literal = game_literal
	stream.seek(48)
	
	var game_version = stream.get_string(32)
	file_data.header.game_version = game_version
	stream.seek(80)
	
	var godot_version = stream.get_string(32)
	file_data.header.godot_version = godot_version
	stream.seek(112)
	
	stream.seek(192)
	
	var toc_checksum_res = stream.get_data(32)
	if toc_checksum_res[0] != OK:
		return FWSaveTypes.Result.failure(FWSaveTypes.Error.CORRUPTED_FILE)
	var toc_checksum = toc_checksum_res[1]
	file_data.header.toc_checksum = toc_checksum
	
	var header_checksum_res = stream.get_data(32)
	if header_checksum_res[0] != OK:
		return FWSaveTypes.Result.failure(FWSaveTypes.Error.CORRUPTED_FILE)
	var header_checksum = header_checksum_res[1]
	file_data.header.header_checksum = header_checksum
	
	return FWSaveTypes.Result.success(file_data)
