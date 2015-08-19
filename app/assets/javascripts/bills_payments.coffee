# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

jQuery ->
  ### Start endless page stuff ###
  loading_bill_payments = false
  $('a.load-more-bill-payments').on 'inview', (e, visible) ->
    return if loading_bill_payments or not visible
    loading_bill_payments = true
    $('#spinner').show()
    $('a.load-more-bill-payments').hide()

    $.getScript $(this).attr('href'), ->
      loading_bill_payments = false
  ### End endless page stuff ###

  ### Re-enable disabled_with buttons for back button ###
  $(document).on 'page:change', ->
    $.rails.enableElement $('#payments_to_open')
    $.rails.enableElement $('#payments_to_closed')
    return