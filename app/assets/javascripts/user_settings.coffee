# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

jQuery ->

  ### Re-enable disabled_with buttons for back button ###
  $(document).on 'page:change', ->
    $.rails.enableElement $('#edit_user_setting_button')
    $.rails.enableElement $('#edit_contract_button')
    $.rails.enableElement $('#new_contract_button')
    return