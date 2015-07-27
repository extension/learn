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
	#if event_id is not in event_registration cookie then hide location and display registration form
	#see learners#register_learner for other actions related to registration cookie
	if $group.length && $('#event_id').val() not in registration_cookie_array
		$(".location").hide()
		$(".location-section").hide()
		$(".submit_register").click ->
			if validateForm() == false
				return false
			else if validateEmail($("#email").val()) == false
				alert('Please enter a valid email address')
				return false
			else
				$(".location").show()
				$(".location-section").show()
				$(".registration_form").hide()
	else
		$(".registration_form").hide()

	#validate email
	validateEmail = (email) ->
	  re = /^([\w-]+(?:\.[\w-]+)*)@((?:[\w-]+\.)*\w[\w-]{0,66})\.([a-z]{2,6}(?:\.[a-z]{2})?)$/i
	  re.test email

	#validate email, first name and last name
	validateForm = ->
		if $("#email").val() == '' || $("#first_name").val() == '' || $("#last_name").val() == ''
				alert('Please enter first name, last name, and email')
				return false

#event new/edit page
$ ->
		if $('#event_requires_registration').prop('checked') == true
				$('#registration_contact').prop 'disabled', false
		else
				$('#registration_contact').prop 'disabled', true
		$('#event_requires_registration').click ->
				$('#registration_contact').attr 'disabled', !@checked
				$('#registration_contact').val('');
				$('#event_registration_contact_id').val('');
				if $('#event_requires_registration').prop('checked') == true
					$('#registration_contact').attr 'placeholder', 'Enter Contact...'
				else
					$('#registration_contact').attr 'placeholder', ''
				return