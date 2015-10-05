# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

jQuery ->

  ### Re-enable disabled_with buttons for back button ###
  $(document).on 'page:change', ->
    $('.item_button').each ->
      $.rails.enableElement $(this)
      return
    return

  ### Start endless page stuff ###
  loading_items = false
  $('a.load-more-items').on 'inview', (e, visible) ->
    return if loading_items or not visible
    loading_items = true
    $('#spinner').show()
    $('a.load-more-items').hide()

    $.getScript $(this).attr('href'), ->
      loading_items = false
  ### End endless page stuff ###