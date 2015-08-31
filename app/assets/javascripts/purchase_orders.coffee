# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

jQuery ->
  $(document).ready ->
    wrapper = $('.purchase_order_input_fields_wrap')
    $(wrapper).on 'click', '.remove_field', (e) ->
      #user click on item trash button
      #if $('.well').length > 2
      if $('.panel').length > 2
        confirm1 = confirm('Are you sure you want to delete this?')
        if confirm1
          e.preventDefault()
          #$(this).closest('.well').remove()
          $(this).closest('.panel').remove()
          return
        else
          e.preventDefault()
          return
      else
        alert 'You cannot delete this because you must have at least one item.'
        e.preventDefault()
        return
    return

  ### Vendor value changed ###
  $('#purchase_order_vendor').on 'change', ->
    input_select = $(this)
    panel = input_select.closest('.panel')
    name = input_select.closest('.panel').find($( "#purchase_order_vendor option:selected" )).text()
    #alert $(this).closest('.panel').find('.vendor_name').text $(this).text()
    input_select.closest('.panel').find('.vendor_name').text name
    panel.closest('.collapse').collapse('toggle')
    $(this).closest('.panel-collapse').collapse('hide');

  ### Line item changed ###
  $('.purchase_order_input_fields_wrap').on 'change', 'select', ->
    item_id = $(this).val()
    input_select = $(this)
    $.ajax(url: "/items/" + item_id, dataType: 'json').done (data) ->
      name = data.name
      description = data.description
      rate = parseFloat(data.unit_price).toFixed(2)
      quantity = 0
      input_select.closest('.panel').find('.panel-footer').text ''
      input_select.closest('.panel').find('.line_item_name').text name
      input_select.siblings("input").each ->
        if $(this).is( "#purchase_order_line_items__rate" )
          $(this).val rate
        if $(this).is( "#purchase_order_line_items__gross" )
          $(this).val 0
        if $(this).is( "#purchase_order_line_items__tare" )
          $(this).val 0
        if $(this).is( "#purchase_order_line_items__quantity" )
          $(this).val 0
        if $(this).is( "#purchase_order_line_items__amount" )
          amount = (parseFloat(rate) * parseFloat(quantity))
          $(this).val amount
        return
      return

  ### Line item calculation field value changed ###
  $('.purchase_order_input_fields_wrap').on 'keyup', '.amount-calculation-field', ->
    if $(this).is( "#purchase_order_line_items__rate" )
      quantity = $(this).prevAll('#purchase_order_line_items__quantity').first().val()
      rate = $(this).val()
      amount = (parseFloat(rate) * parseFloat(quantity)).toFixed(2)
      $(this).nextAll('#purchase_order_line_items__amount').first().val amount
    if $(this).is( "#purchase_order_line_items__gross" )
      gross = $(this).val()
      tare = $(this).nextAll('#purchase_order_line_items__tare').first().val()
      rate = $(this).nextAll('#purchase_order_line_items__rate').first().val()
      quantity = (parseFloat(gross) - parseFloat(tare))
      $(this).nextAll('#purchase_order_line_items__quantity').first().val quantity
      amount = (parseFloat(rate) * parseFloat(quantity)).toFixed(2)
      $(this).nextAll('#purchase_order_line_items__amount').first().val amount
    if $(this).is( "#purchase_order_line_items__tare" )
      gross = $(this).prevAll('#purchase_order_line_items__gross').first().val()
      tare = $(this).val()
      rate = $(this).nextAll('#purchase_order_line_items__rate').first().val()
      quantity = (parseFloat(gross) - parseFloat(tare))
      $(this).nextAll('#purchase_order_line_items__quantity').first().val quantity
      amount = (parseFloat(rate) * parseFloat(quantity)).toFixed(2)
      $(this).nextAll('#purchase_order_line_items__amount').first().val amount
    if $(this).is( "#purchase_order_line_items__quantity" )
      rate = $(this).nextAll('#purchase_order_line_items__rate').first().val()
      quantity = $(this).val()
      amount = (parseFloat(rate) * parseFloat(quantity)).toFixed(2)
      $(this).nextAll('#purchase_order_line_items__amount').first().val amount
    gross = $(this).closest('.panel').find('#purchase_order_line_items__gross').val()
    tare = $(this).closest('.panel').find('#purchase_order_line_items__tare').val()
    quantity = $(this).closest('.panel').find('#purchase_order_line_items__quantity').val()
    rate = $(this).closest('.panel').find('#purchase_order_line_items__rate').val()
    amount = $(this).closest('.panel').find('#purchase_order_line_items__amount').val()
    $(this).closest('.panel').find('.panel-footer').text 'G: ' + gross + ' ' + 'T: ' + tare + ' ' + 'N: ' + quantity + ' '  + 'R: $' + rate + ' ' +  'T: $' + amount
    return

  ### Re-enable disabled_with buttons for back button ###
  $(document).on 'page:change', ->
    $.rails.enableElement $('#purchase_orders_to_closed')
    $.rails.enableElement $('#purchase_orders_to_paid')
    return

  ### Start endless page stuff ###
  loading_purchase_orders = false
  $('a.load-more-purchase-orders').on 'inview', (e, visible) ->
    return if loading_purchase_orders or not visible
    loading_purchase_orders = true
    $('#spinner').show()
    $('a.load-more-purchase-orders').hide()

    $.getScript $(this).attr('href'), ->
      loading_purchase_orders = false
  ### End endless page stuff ###