# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

#event show page

$ ->
 $('#event_registration_contact_id').autocomplete
    source: $('#event_registration_contact_id').data('autocomplete-source')

$ ->
	$group = $('.form-group.registration_form')
	if $group.length
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
	if $('#event_requires_registration').is ':checked'
		$('.token-input-list-facebook').show()
	else
		$('.token-input-list-facebook').hide()
	$('#event_requires_registration').change ->
		$('.token-input-list-facebook').toggle @checked
		return