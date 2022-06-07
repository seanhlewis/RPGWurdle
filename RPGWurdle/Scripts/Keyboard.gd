extends VBoxContainer



func _ready()->void :
	for key in get_tree().get_nodes_in_group("LetterKeys"):
		key.connect("pressed", self, "_send_letter_key_input_event", [_char_to_ascii_int(key.text.to_lower())])


func change_letter_key_color(letter:String, check_letter:int)->void :
	for key in get_tree().get_nodes_in_group("LetterKeys"):
		if letter == key.text.to_lower():
			match check_letter:
				Globals.CheckLetter.NOT_CHECKED:
					key.self_modulate = Color.white
				Globals.CheckLetter.NOT_IN_WORD:
					if key.self_modulate != Color.yellow and key.self_modulate != Color.yellowgreen:
						key.self_modulate = Color.red
				Globals.CheckLetter.WRONG_PLACE:
					if key.self_modulate != Color.yellowgreen:
						key.self_modulate = Color.yellow
				Globals.CheckLetter.CORRECT:
					key.self_modulate = Color.yellowgreen


func _char_to_ascii_int(letter:String)->int:
	var buffer: = StreamPeerBuffer.new()
	buffer.data_array = letter.to_ascii()
	return buffer.get_8()


func _send_letter_key_input_event(unicode:int)->void :
	var event: = InputEventKey.new()
	event.pressed = true
	event.unicode = unicode
	Input.parse_input_event(event)


func _on_BackSpace_pressed()->void :
	var event: = InputEventKey.new()
	event.pressed = true
	event.scancode = KEY_BACKSPACE
	Input.parse_input_event(event)


func _on_Enter_pressed()->void :
	var event: = InputEventKey.new()
	event.pressed = true
	event.scancode = KEY_ENTER
	Input.parse_input_event(event)
