# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$("#user_selected_timezone_timezone").live "change", ->
  $.cookie 'user_selected_timezone', this.value, path: '/'
  location.reload()