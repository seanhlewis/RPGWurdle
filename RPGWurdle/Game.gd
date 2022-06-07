extends Node


var word_to_guess: = ""
var word_attempt: = ""
var previous_attempt_list = []

var current_attempt: = 1
var current_letter: = 1


onready  var word_rows: = [
	$Words / WordRows / WordRow1, 
	$Words / WordRows / WordRow2, 
	$Words / WordRows / WordRow3, 
	$Words / WordRows / WordRow4, 
	$Words / WordRows / WordRow5, 
	$Words / WordRows / WordRow6, 
]


func _ready():
	word_to_guess = WordList.get_todays_word()
	$Foreground/FGX/FG/enemy/anim.connect("animation_finished", self, "enemy_idle")
	$Foreground/FGX/FG/player/anim.connect("animation_finished", self, "player_idle")
	
	#BG SET
	$BG/Fanim.seek(Globals.Tfanim)
	$BG/Fanim2.seek(Globals.Tfanim2)
	$BG/Fanim3.seek(Globals.Tfanim3)
	$skycolor/anim.seek(Globals.Canim)
	
	if Globals.settings:
		$Words/SETTINGS/Sanim.play("open_settings")
		$Words/SETTINGS/Sanim.seek(2.9)
	
	if Globals.slimecolor:
		Globals.slimecolor = false
		var rslime = floor(rand_range(0,4))
		#print("changing slime color")
		#print(rslime)
		match int(rslime):
			0:
				$Foreground/FGX/FG/enemy.texture = preload("res://Assets/Enemies/greenslime.png")
			1:
				$Foreground/FGX/FG/enemy.texture = preload("res://Assets/Enemies/blueslime.png")
			2:
				$Foreground/FGX/FG/enemy.texture = preload("res://Assets/Enemies/pinkslime.png")
			3:
				$Foreground/FGX/FG/enemy.texture = preload("res://Assets/Enemies/yellowslime.png")
		
	match Globals.enemy:
		"slime":
			$Foreground/FGX/FG/enemy/anim.play("slime_idle")
		"skeleton":
			$Foreground/FGX/FG/enemy/anim.play("skeleton_idle")


func _input(event):
	#print("detect input")
	if event is InputEventKey and event.pressed and !Globals.gameover:
		if event.unicode != 0:
			var letter: = char(event.unicode).to_upper()
			if current_letter <= 5:
				word_attempt += letter
				update_letter_panel(letter, current_attempt, current_letter)
				current_letter += 1
		elif event.scancode == KEY_BACKSPACE:
			if current_letter > 1:
				current_letter -= 1
			word_attempt.erase(current_letter - 1, 1)
			update_letter_panel("", current_attempt, current_letter)
		elif event.scancode == KEY_ENTER:
			if word_attempt.length() < 5:
				$Words / WordRows / center / Message.text = "\nType 5 letters"
				return 
			word_attempt = word_attempt.to_lower()
			var attempt_result: = check_word(word_attempt, word_to_guess)
			if attempt_result[0] == Globals.CheckLetter.NOT_CHECKED:
				$Words / WordRows / center / Message.text = "\nNot in dictionary"
				return 
			if word_attempt.to_lower() in previous_attempt_list:
				$Words / WordRows / center / Message.text = "\nDuplicate word"
				return
			for i in range(5):
				update_color_panel(attempt_result[i], current_attempt, i + 1)
				$Words/Keyboard.change_letter_key_color(word_attempt[i], attempt_result[i])
			if word_attempt == word_to_guess:
				$Words / WordRows / center / Message.text = "\nYou Win!"
				#set_process_input(false)
				Globals.win_achieve_check()
				Globals.gameover = true
				return 
			current_attempt += 1
			if current_attempt > 6:
				$Words / WordRows / center / Message.text = "\nThe word was: " + word_to_guess
				#set_process_input(false)
				Globals.gameover = true
				return 
			#print(previous_attempt_list)
			previous_attempt_list.append(word_attempt.to_lower())
			current_letter = 1
			word_attempt = ""
			$Words / WordRows / center / Message.text = "\nRPG Wurdle"
			
		
	elif event is InputEventKey && Globals.gameover:
		#print(event)
		Globals.enter += 1
		if event.scancode == KEY_ENTER and Globals.enter > 1:
			Globals.enter = 0
			Globals.gameover = false
			Globals.win = false
			Globals.wcount = 0
			randomize()
			var renemy = floor(rand_range(0,2))
			match int(renemy):
				0:
					Globals.enemy = "slime"
					Globals.slimecolor = true
				1:
					Globals.enemy = "skeleton"
			#RESET THE GAME
			#BG save
			Globals.Tfanim = $BG/Fanim.current_animation_position
			Globals.Tfanim2 = $BG/Fanim2.current_animation_position
			Globals.Tfanim3 = $BG/Fanim3.current_animation_position
			
			get_tree().reload_current_scene()
		
			
			
			

func check_word(word:String, correct_word:String)->Array:
	if Globals.keyboard:
		OS.show_virtual_keyboard("", false)
	var result: = [
		Globals.CheckLetter.NOT_CHECKED, 
		Globals.CheckLetter.NOT_CHECKED, 
		Globals.CheckLetter.NOT_CHECKED, 
		Globals.CheckLetter.NOT_CHECKED, 
		Globals.CheckLetter.NOT_CHECKED, 
	]
	var correct_letter_count: = {}

	if not (word in WordList.DICTIONARY) and not (word in WordList.WORDS):
		return result

	for letter in correct_word:
		correct_letter_count[letter] = correct_letter_count.get(letter, 0) + 1

	for i in range(5):
		if word[i] == correct_word[i]:
			result[i] = Globals.CheckLetter.CORRECT
			correct_letter_count[word[i]] -= 1

	for i in range(5):
		if result[i] == Globals.CheckLetter.CORRECT:
			Globals.gcount += 1
			continue
		elif word[i] in correct_word and correct_letter_count.get(word[i], 0) > 0:
			result[i] = Globals.CheckLetter.WRONG_PLACE
			correct_letter_count[word[i]] -= 1
		else :
			result[i] = Globals.CheckLetter.NOT_IN_WORD
			
	
	return result


func update_letter_panel(letter:String, attempt_number:int, letter_number:int)->void :
	word_rows[attempt_number - 1].get_node("Letter" + str(letter_number) + "/Letter").text = letter

func update_color_panel(check_letter:int, attempt_number:int, letter_number:int)->void :
	var panel:ColorRect = word_rows[attempt_number - 1].get_node("Letter" + str(letter_number))
	match check_letter:
		Globals.CheckLetter.NOT_IN_WORD:
			panel.color = Color.black
			Globals.black = true
		Globals.CheckLetter.WRONG_PLACE:
			panel.color = Color.yellow
			Globals.yellow = true
		Globals.CheckLetter.CORRECT:
			panel.color = Color.yellowgreen
			Globals.green = true
	Globals.counter += 1
	if Globals.counter >= 5:
		Globals.wcount += 1
		Globals.counter = 0
		#print(Globals.black, Globals.yellow, Globals.green)
		#Who attacks who!!
		if !Globals.yellow && !Globals.green:
			#print("enemy attack")
			match Globals.enemy:
				"slime":
					$Foreground/FGX/FG/enemy/anim.play("slime_attack")
				"skeleton":
					$Foreground/FGX/FG/enemy/anim.play("skeleton_attack")
		if (Globals.yellow || Globals.green) && Globals.wcount <= 6:
			if (Globals.wcount >= 6 && Globals.gcount < 5) || !Globals.green:
				#Player has lost
				#print("lost")
				match Globals.enemy:
					"slime":
						$Foreground/FGX/FG/enemy/anim.play("slime_attack")
					"skeleton":
						$Foreground/FGX/FG/enemy/anim.play("skeleton_attack")
			else:
				#print("player attack
				randomize()
				var rint = floor(rand_range(0,3))
				#print(rint)
				match int(rint):
					0:
						$Foreground/FGX/FG/player/anim.play("attack1")
					1:
						$Foreground/FGX/FG/player/anim.play("attack2")
					2:
						$Foreground/FGX/FG/player/anim.play("attack3")
					
				if Globals.gcount >= 5:
					#print("heck yeah")
					Globals.win = true
					match Globals.enemy:
						"slime":
							$Foreground/FGX/FG/enemy/anim.play("slime_die")
						"skeleton":
							$Foreground/FGX/FG/enemy/anim.play("skeleton_die")
				
				else:
					randomize()
					rint = floor(rand_range(0,2))
					match int(rint):
						0:
							match Globals.enemy:
								"slime":
									$Foreground/FGX/FG/enemy/anim.play("slime_roll")
								"skeleton":
									$Foreground/FGX/FG/enemy/anim.play("skeleton_hurt")
						1:
							match Globals.enemy:
								"slime":
									$Foreground/FGX/FG/enemy/anim.play("slime_jump")
								"skeleton":
									$Foreground/FGX/FG/enemy/anim.play("skeleton_react")
							

		Globals.gcount = 0
		Globals.black = false
		Globals.yellow = false
		Globals.green = false

func player_idle(anim):
	if anim != "idle" && Globals.wcount >= 6 && !Globals.win:
		$Foreground/FGX/FG/player/anim.play("shield")
	elif anim != "idle" && !Globals.win:
		$Foreground/FGX/FG/player/anim.play("idle")
	elif anim != "idle" && anim != "raise_sword":
		$Foreground/FGX/FG/player/anim.play("raise_sword")
	elif anim != "idle":
		$Foreground/FGX/FG/player/anim.play("hold_sword")
	else:
		pass

func enemy_idle(anim):
	match Globals.enemy:
		"slime":
			if anim != "slime_idle" && anim != "slime_attack" && anim != "slime_die":
				$Foreground/FGX/FG/enemy/anim.play("slime_idle")
			elif anim == "slime_attack":
				$Foreground/FGX/FG/player/anim.play("hurt")
				$Foreground/FGX/FG/enemy/anim.play("slime_idle")
			else:
				pass
		"skeleton":
			if anim != "skeleton_idle" && anim != "skeleton_attack" && anim != "skeleton_die":
				$Foreground/FGX/FG/enemy/anim.play("skeleton_idle")
			elif anim == "skeleton_attack":
				$Foreground/FGX/FG/player/anim.play("hurt")
				$Foreground/FGX/FG/enemy/anim.play("skeleton_idle")
			else:
				pass
	

func RESET_pressed():
	Globals.enter = 0
	Globals.gameover = false
	Globals.win = false
	Globals.wcount = 0
	#RESET THE GAME
	#BG save
	Globals.Tfanim = $BG/Fanim.current_animation_position
	Globals.Tfanim2 = $BG/Fanim2.current_animation_position
	Globals.Tfanim3 = $BG/Fanim3.current_animation_position
	Globals.Canim = $skycolor/anim.current_animation_position
	Globals.Sanim = $Words/SETTINGS/Sanim.current_animation_position
	
	get_tree().reload_current_scene()
	
	
	

func KEYBOARD_pressed():
	if Globals.settings:
		if !Globals.keyboard:
			Globals.keyboard = true
			$Words/MENU/keyboardbtn.texture_normal = preload("res://Assets/UI/keyboardON.png")
			$Words/MENU/keyboardbtn.release_focus()
			$Foreground/FGX.anchor_top = 0.01 #DEFAULT 0.1
			$Foreground/FGX.anchor_bottom = 0.01 #DEFAULT 0.1
			OS.show_virtual_keyboard("", false)
			
		elif Globals.keyboard:
			Globals.keyboard = false
			$Words/MENU/keyboardbtn.texture_normal = preload("res://Assets/UI/keyboard.png")
			$Foreground/FGX.anchor_top = 0.1
			$Foreground/FGX.anchor_bottom = 0.1
			OS.hide_virtual_keyboard()


func DAYNIGHT_pressed():
	if Globals.settings:
		if Globals.daynight <= 0:
			$Words/MENU/daynightbtn.texture_normal = preload("res://Assets/UI/daynightN.png")
			Globals.daynight = 1
			$skycolor.visible = false
			#Daytime only
		elif Globals.daynight == 1:
			$Words/MENU/daynightbtn.texture_normal = preload("res://Assets/UI/daynightD.png")
			Globals.daynight = 2
			$skycolor.visible = true
			$skycolor/anim.seek(120.0)
			$skycolor/anim.pause_mode = true
			#if !Globals.vamp_achieve:
			#	Globals.vamp_achieve = true
			GooglePlay.play_services.unlockAchievement(GooglePlay.vampire_achievement)
			#Nighttime only
		elif Globals.daynight >= 2:
			$Words/MENU/daynightbtn.texture_normal = preload("res://Assets/UI/daynight.png")
			Globals.daynight = 0
			$skycolor.visible = true
			$skycolor/anim.seek(0.0)
			$skycolor/anim.pause_mode = false
			#Cycle

func SETTINGS_pressed():
	if !Globals.settings:
		Globals.settings = true
		#if !GooglePlay.is_signed_in:
		#	$Words/MENU/trophybtn.visible = false
		#	$Words/MENU.margin_bottom = 150
		#else:
		#	$Words/MENU/trophybtn.visible = true
		#	$Words/MENU.margin_bottom = 225
		$Words/SETTINGS/Sanim.play("open_settings")
	elif Globals.settings:
		Globals.settings = false
		$Words/SETTINGS/Sanim.play_backwards("open_settings")


func TROPHY_pressed():
	if !GooglePlay.is_signed_in:
		GooglePlay.sign_in()
	else:
		GooglePlay.show_achievements()

func fullday_achievement():
	#if !Globals.day_achieve:
	#	Globals.day_achieve = true
	GooglePlay.play_services.unlockAchievement(GooglePlay.fullday_achievement)



