# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

jQuery ->
	if $('div').hasClass 'form-group registration_form'
		$(".location").hide()
		$(".submit_register").click ->
			$(".location").show()
			$(".registration_form").hide()