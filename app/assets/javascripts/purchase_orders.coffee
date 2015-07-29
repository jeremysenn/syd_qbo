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

  $('.input_fields_wrap').on 'change', 'select', ->
    #alert($(this).val())
    item_id = $(this).val()
    input_select = $(this)
    $.ajax(url: "/items/" + item_id, dataType: 'json').done (data) ->
      name = data.name
      description = data.description
      rate = data.unit_price
      quantity = 0
      input_select.closest('.well').find('.toggle_link').show()
      input_select.closest('.well').find('.toggle_link').text name + ' (' + description + ')'
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
    
    #description = $(this).find(":selected").data("description")
    #rate = $(this).find(":selected").data("rate")
    #quantity = 1
    #$(this).siblings("input").each ->
      #alert($(this).val())
      #if $(this).is( "#purchase_order_line_items__description" )
      #  $(this).val description
      #if $(this).is( "#purchase_order_line_items__rate" )
      #  $(this).val rate
      #if $(this).is( "#purchase_order_line_items__quantity" )
      #  $(this).val 1
      #if $(this).is( "#purchase_order_line_items__amount" )
      #  amount = (parseFloat(rate) * parseFloat(quantity))
      #  $(this).val amount
      #return
    #return

  #$('.amount-calculation-field').keyup ->
  $('.input_fields_wrap').on 'keyup', '.amount-calculation-field', ->
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
      amount = (parseFloat(rate) * parseFloat(quantity)).toFixed(2)
      $(this).nextAll('#purchase_order_line_items__quantity').first().val quantity
      $(this).nextAll('#purchase_order_line_items__amount').first().val amount
    if $(this).is( "#purchase_order_line_items__tare" )
      gross = $(this).prevAll('#purchase_order_line_items__gross').first().val()
      tare = $(this).val()
      rate = $(this).nextAll('#purchase_order_line_items__rate').first().val()
      quantity = (parseFloat(gross) - parseFloat(tare))
      amount = (parseFloat(rate) * parseFloat(quantity)).toFixed(2)
      $(this).nextAll('#purchase_order_line_items__quantity').first().val quantity
      $(this).nextAll('#purchase_order_line_items__amount').first().val amount
    if $(this).is( "#purchase_order_line_items__quantity" )
      rate = $(this).nextAll('#purchase_order_line_items__rate').first().val()
      quantity = $(this).val()
      amount = (parseFloat(rate) * parseFloat(quantity)).toFixed(2)
      $(this).nextAll('#purchase_order_line_items__amount').first().val amount
    return