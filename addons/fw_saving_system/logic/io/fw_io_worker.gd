
class_name FWIoWorker
extends RefCounted

const MAGIC_NUMBER_SIZE = 4
const GAME_LITERAL_SIZE = 32
const GAME_VERSION_SIZE = 32
const GODOT_VERSION_SIZE = 32

var magic_number: PackedByteArray
var game_literal: PackedByteArray
var game_version: PackedByteArray
var godot_version: PackedByteArray

func _init(magic_num: StringName, game_lit: StringName, game_vers: StringName, godot_vers: StringName):
	magic_number = _adapt_string_to_buf(magic_num, MAGIC_NUMBER_SIZE)
	game_literal = _adapt_string_to_buf(game_lit, GAME_LITERAL_SIZE)
	game_version = _adapt_string_to_buf(game_vers, GAME_VERSION_SIZE)
	godot_version = _adapt_string_to_buf(godot_vers, GODOT_VERSION_SIZE)

func _adapt_string_to_buf(str: StringName, size: int) -> PackedByteArray:
	var buf: PackedByteArray = str.to_ascii_buffer()

	if buf.size() > size:
		buf.resize(size)
	if buf.size() < size:
		var pad: PackedByteArray = PackedByteArray()
		pad.resize(size - buf.size())
		pad.fill(0)

		buf.append_array(pad)

	return buf

# TODO: func _decode_v1(
