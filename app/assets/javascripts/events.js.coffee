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
			$(".location").show()
			$(".location-section").show()
			$(".registration_form").hide()
	else
		$(".registration_form").hide()

#event new/edit page
$ ->
		if $('#event_requires_registration').prop('checked') == true
				$('#registration_contact').prop 'disabled', false
				$('#event_registration_description').prop 'disabled', false
		else
				$('#registration_contact').prop 'disabled', true
				$('#event_registration_description').prop 'disabled', true
		$('#event_requires_registration').click ->
				$('#registration_contact').attr 'disabled', !@checked
				$('#registration_contact').val('');
				$('#event_registration_contact_id').val('');
				$('#event_registration_description').val('');
				if $('#event_requires_registration').prop('checked') == true
					$('#registration_contact').attr 'placeholder', 'Enter Contact...'
					$('#event_registration_description').attr 'placeholder', 'Enter description to be emailed (optional)...'
				else
					$('#registration_contact').attr 'placeholder', ''
					$('#event_registration_description').attr 'placeholder', ''
				return