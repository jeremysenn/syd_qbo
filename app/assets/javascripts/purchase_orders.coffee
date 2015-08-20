# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

jQuery ->
  $(document).ready ->
    wrapper = $('.purchase_order_input_fields_wrap')
    $(wrapper).on 'click', '.remove_field', (e) ->
      #user click on item trash button
      if $('.well').length > 2
        confirm1 = confirm('Are you sure you want to delete this?')
        if confirm1
          e.preventDefault()
          $(this).closest('.well').remove()
          return
        else
          e.preventDefault()
          return
      else
        alert 'You cannot delete this because you must have at least one item.'
        e.preventDefault()
        return
    return

  $('.purchase_order_input_fields_wrap').on 'change', 'select', ->
    #alert($(this).val())
    item_id = $(this).val()
    input_select = $(this)
    $.ajax(url: "/items/" + item_id, dataType: 'json').done (data) ->
      name = data.name
      description = data.description
      rate = parseFloat(data.unit_price).toFixed(2)
      quantity = 0
      input_select.closest('.well').find('.toggle_link').show()
      input_select.closest('.well').find('.toggle_link').text name
      #input_select.closest('.well').find('.toggle_link').html '<p>' + name + ' (' + description + ')' + '<br>' + 0 + '<br>' + '$' + rate + '</p>'
      #input_select.closest('.toggle_link').show()
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

  #$('.amount-calculation-field').keyup ->
  $('.purchase_order_input_fields_wrap').on 'keyup', '.amount-calculation-field', ->
    if $(this).is( "#purchase_order_line_items__rate" )
      quantity = $(this).prevAll('#purchase_order_line_items__quantity').first().val()
      rate = $(this).val()
      $(this).closest('.calculation_fields').nextAll('#quantity_preview').text "Net: " + quantity
      $(this).closest('.calculation_fields').nextAll('#unit_price_preview').text "Rate: " + "$" + rate
      amount = (parseFloat(rate) * parseFloat(quantity)).toFixed(2)
      $(this).nextAll('#purchase_order_line_items__amount').first().val amount
    if $(this).is( "#purchase_order_line_items__gross" )
      gross = $(this).val()
      tare = $(this).nextAll('#purchase_order_line_items__tare').first().val()
      rate = $(this).nextAll('#purchase_order_line_items__rate').first().val()
      quantity = (parseFloat(gross) - parseFloat(tare))
      amount = (parseFloat(rate) * parseFloat(quantity)).toFixed(2)
      $(this).closest('.calculation_fields').nextAll('#quantity_preview').text "Net: " + quantity
      $(this).closest('.calculation_fields').nextAll('#unit_price_preview').text "Rate: " + "$" + rate
      $(this).nextAll('#purchase_order_line_items__quantity').first().val quantity
      $(this).closest('.calculation_fields').nextAll('#quantity_preview').text "Net: " + quantity
      $(this).nextAll('#purchase_order_line_items__amount').first().val amount
    if $(this).is( "#purchase_order_line_items__tare" )
      gross = $(this).prevAll('#purchase_order_line_items__gross').first().val()
      tare = $(this).val()
      rate = $(this).nextAll('#purchase_order_line_items__rate').first().val()
      quantity = (parseFloat(gross) - parseFloat(tare))
      amount = (parseFloat(rate) * parseFloat(quantity)).toFixed(2)
      $(this).closest('.calculation_fields').nextAll('#quantity_preview').text "Net: " + quantity
      $(this).closest('.calculation_fields').nextAll('#unit_price_preview').text "Rate: " + "$" + rate
      $(this).nextAll('#purchase_order_line_items__quantity').first().val quantity
      $(this).closest('.calculation_fields').nextAll('#quantity_preview').text "Net: " + quantity
      $(this).nextAll('#purchase_order_line_items__amount').first().val amount
    if $(this).is( "#purchase_order_line_items__quantity" )
      rate = $(this).nextAll('#purchase_order_line_items__rate').first().val()
      quantity = $(this).val()
      amount = (parseFloat(rate) * parseFloat(quantity)).toFixed(2)
      $(this).nextAll('#purchase_order_line_items__amount').first().val amount
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