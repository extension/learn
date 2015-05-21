# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

jQuery ->
	if $('div').hasClass 'form-group registration_form'
		$(".location").hide()
		$(".submit_register").click ->
			if $("#email").val() == '' || $("#first_name").val() == '' || $("#last_name").val() == ''
				alert('Please enter first name, last name, and email')
			else if validateEmail($("#email").val()) == false
				alert('Please enter a valid email address')
				return false
			else
				$(".location").show()
				$(".registration_form").hide()

	#validate email
	validateEmail = (email) ->
	  re = /^([\w-]+(?:\.[\w-]+)*)@((?:[\w-]+\.)*\w[\w-]{0,66})\.([a-z]{2,6}(?:\.[a-z]{2})?)$/i
	  re.test email