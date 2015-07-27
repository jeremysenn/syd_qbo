# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

jQuery ->
  ### Start endless page stuff ###
  loading_shipments = false
  $('a.load-more-shipments').on 'inview', (e, visible) ->
    return if loading_shipments or not visible
    loading_shipments = true
    $('#spinner').show()
    $('a.load-more-shipments').hide()

    $.getScript $(this).attr('href'), ->
      loading_shipments = false
  ### End endless page stuff ###