extends Node

var black = false
var yellow = false
var green = false
var counter = 0
var gcount = 0
var wcount = 0

var win = false
var gameover = false

var enter = 0

var debug = false
#BG INFO
var Tfanim = 0.0
var Tfanim2 = 0.0
var Tfanim3 = 0.0
var Canim = 0.0

var enemy = "slime"
var slimecolor = false

var keyboard = false
var settings = false
var Sanim = 0.0

var daynight = 0



enum CheckLetter{
	NOT_CHECKED, 
	NOT_IN_WORD, 
	WRONG_PLACE, 
	CORRECT, 
}

func win_achieve_check():
	if GooglePlay.permanent_sign_in and !GooglePlay.is_signed_in:
		GooglePlay.sign_in()
	GooglePlay.play_services.incrementAchievement(GooglePlay.novice_achievement, 1)
	GooglePlay.play_services.incrementAchievement(GooglePlay.apprentice_achievement, 1)
	GooglePlay.play_services.incrementAchievement(GooglePlay.squire_achievement, 1)
	GooglePlay.play_services.incrementAchievement(GooglePlay.knight_achievement, 1)
	GooglePlay.play_services.incrementAchievement(GooglePlay.wizard_achievement, 1)
	#if !Globals.first_achieve:
	#	Globals.first_achieve = true
	GooglePlay.play_services.unlockAchievement(GooglePlay.first_achievement)
