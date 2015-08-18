# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

jQuery ->
  $(document).ready ->
    wrapper = $('.input_fields_wrap')
    $(wrapper).on 'click', '.remove_field', (e) ->
      #user click on item trash button
      e.preventDefault()
      $(this).closest('.well').remove()
      return
    return

  $('.bill_input_fields_wrap').on 'change', 'select', ->
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
      input_select.siblings("input").each ->
        if $(this).is( "#bill_line_items__rate" )
          $(this).val rate
        if $(this).is( "#bill_line_items__gross" )
          $(this).val 0
        if $(this).is( "#bill_line_items__tare" )
          $(this).val 0
        if $(this).is( "#bill_line_items__quantity" )
          $(this).val 0
        if $(this).is( "#bill_line_items__amount" )
          amount = (parseFloat(rate) * parseFloat(quantity))
          $(this).val amount
        return
      return
    
  $('.bill_input_fields_wrap').on 'keyup', '.amount-calculation-field', ->
    if $(this).is( "#bill_line_items__rate" )
      quantity = $(this).prevAll('#bill_line_items__quantity').first().val()
      rate = $(this).val()
      $(this).closest('.calculation_fields').nextAll('#quantity_preview').text "Load: " + quantity
      $(this).closest('.calculation_fields').nextAll('#unit_price_preview').text "Rate: " + "$" + rate
      amount = (parseFloat(rate) * parseFloat(quantity)).toFixed(2)
      $(this).nextAll('#bill_line_items__amount').first().val amount
    if $(this).is( "#bill_line_items__gross" )
      gross = $(this).val()
      tare = $(this).nextAll('#bill_line_items__tare').first().val()
      rate = $(this).nextAll('#bill_line_items__rate').first().val()
      quantity = (parseFloat(gross) - parseFloat(tare))
      amount = (parseFloat(rate) * parseFloat(quantity)).toFixed(2)
      $(this).closest('.calculation_fields').nextAll('#quantity_preview').text "Load: " + quantity
      $(this).closest('.calculation_fields').nextAll('#unit_price_preview').text "Rate: " + "$" + rate
      $(this).nextAll('#bill_line_items__quantity').first().val quantity
      $(this).nextAll('#bill_line_items__amount').first().val amount
    if $(this).is( "#bill_line_items__tare" )
      gross = $(this).prevAll('#bill_line_items__gross').first().val()
      tare = $(this).val()
      rate = $(this).nextAll('#bill_line_items__rate').first().val()
      quantity = (parseFloat(gross) - parseFloat(tare))
      amount = (parseFloat(rate) * parseFloat(quantity)).toFixed(2)
      $(this).closest('.calculation_fields').nextAll('#quantity_preview').text "Load: " + quantity
      $(this).closest('.calculation_fields').nextAll('#unit_price_preview').text "Rate: " + "$" + rate
      $(this).nextAll('#bill_line_items__quantity').first().val quantity
      $(this).nextAll('#bill_line_items__amount').first().val amount
    if $(this).is( "#bill_line_items__quantity" )
      rate = $(this).nextAll('#bill_line_items__rate').first().val()
      quantity = $(this).val()
      amount = (parseFloat(rate) * parseFloat(quantity)).toFixed(2)
      $(this).nextAll('#bill_line_items__amount').first().val amount
    return