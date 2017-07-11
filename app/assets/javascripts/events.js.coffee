# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

#event show page
$ ->
	$group = $('.form-group.registration_form')
	#check for event_registration cookie and split and convert to array; if it does not exsist set to empty array
	if $.cookie 'event_registration'
		registration_cookie_array = $.cookie('event_registration').split('&')
	else
		registration_cookie_array = []
	#if event_id is not in event_registration cookie then hide location, otherwise hide registration form
	#see learners#register_learner for other actions related to registration cookie
	if $group.length && $('#event_id').val() not in registration_cookie_array
		$(".location").hide()
		$(".location-section").hide()
	else
		$(".registration_form").hide()
