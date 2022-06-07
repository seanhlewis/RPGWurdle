extends Node

var play_services = null
var is_signed_in = false
var permanent_sign_in = false

# Called when the node enters the scene tree for the first time.
func _ready():
	if Engine.has_singleton("GodotPlayGamesServices"):
		play_services = Engine.get_singleton("GodotPlayGamesServices")
		
		var show_popups = true
		var request_email = false
		var request_profile = false
		var request_token = "37528374271-skvs74neb5pa2rcng6b5ktq37b5dvhgl.apps.googleusercontent.com"
		
		play_services.init(show_popups, request_email, request_profile, request_token)
		play_services.connect("_on_sign_in_success", self, "_on_sign_in_success")
		play_services.connect("_on_sign_in_failed", self, "_on_sign_in_failed")
	



func sign_in():
	if play_services:
		play_services.signIn()
	pass


func _on_sign_in_success(userProfile_json : String) -> void:
	print("Successfully signed in")
	GooglePlay.play_services.unlockAchievement(GooglePlay.begin_achievement)
	permanent_sign_in = true
	is_signed_in = true



func _on_sign_in_failed(error) -> void:
	print("Error: %s" % str(error))
	is_signed_in = false
	
func show_achievements():
	play_services.showAchievements()
	
#ACHIEVEMENTS
var begin_achievement = 'CgkI_5f25osBEAIQAQ'
var first_achievement = 'CgkI_5f25osBEAIQAg'
var novice_achievement = 'CgkI_5f25osBEAIQAw'
var apprentice_achievement = 'CgkI_5f25osBEAIQBg'
var squire_achievement = 'CgkI_5f25osBEAIQBw'
var knight_achievement = 'CgkI_5f25osBEAIQCA'
var wizard_achievement = 'CgkI_5f25osBEAIQCQ'
var vampire_achievement = 'CgkI_5f25osBEAIQBA'
var fullday_achievement = 'CgkI_5f25osBEAIQBQ'

