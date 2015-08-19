# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

jQuery ->
  ### Re-enable disabled_with buttons for back button ###
  $(document).on 'page:change', ->
    $.rails.enableElement $('#welcome_to_new_ticket')
    $.rails.enableElement $('#welcome_to_open')
    $.rails.enableElement $('#welcome_to_closed')
    $.rails.enableElement $('#welcome_to_paid')
    $.rails.enableElement $('#welcome_to_search_pictures')
    return