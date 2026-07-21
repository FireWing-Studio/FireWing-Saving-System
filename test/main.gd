extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print(FWBinaryParser.MAGIC_NUMBER)
	print(FWSaveTypes.Result.failure(1000))
	
	var bytes = FileAccess.get_file_as_bytes("res://test/test.bin")
	var parser = FWBinaryParser.new("a", "b", "c")
	var data = parser.decode(bytes).value as FWSaveTypes.FileData
	print(data.header.version)
	print(data.header.file_size)
	print(data.header.toc_count)
	print(data.header.flags)
	print(data.header.game_literal)
	print(data.header.game_version)
	print(data.header.godot_version)
	print(data.header.toc_checksum)
	print(data.header.header_checksum)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
