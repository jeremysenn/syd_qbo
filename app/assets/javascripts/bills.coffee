# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

jQuery ->
  $(document).ready ->
    wrapper = $('.bill_input_fields_wrap')
    $(wrapper).on 'click', '.remove_field', (e) ->
      #user click on item trash button
      if $('.panel').length > 2
        confirm1 = confirm('Are you sure you want to delete this?')
        if confirm1
          e.preventDefault()
          $(this).closest('.panel').remove()
          sum = 0;
          $('.amount').each ->
            sum += Number($(this).val())
            return
          $('#total').text '$' + sum.toFixed(2)
          return
        else
          e.preventDefault()
          return
      else
        alert 'You cannot delete this because you must have at least one item.'
        e.preventDefault()
        return

    # Automatically highlight field value when focused
    $(wrapper).on 'click', '.amount-calculation-field', (e) ->
      $(this).select()
      return

    return

  ### Vendor value changed ###
  $('#bill_vendor').on 'change', ->
    input_select = $(this)
    vendor_id = input_select.val()
    panel = input_select.closest('.panel')
    name = input_select.closest('.panel').find($( "#bill_vendor option:selected" )).text()
    #input_select.closest('.panel').find('.vendor_name').text name
    panel.closest('.collapse').collapse('toggle')
    $(this).closest('.panel-collapse').collapse('hide')
    input_select.closest('.panel').find('#edit_vendor_link').attr('href', "/vendors/" + vendor_id + "/edit"); 
    input_select.closest('.panel').find('#edit_vendor_link').text name

  ### Line item changed ###
  $('.bill_input_fields_wrap').on 'change', 'select', ->
    item_id = $(this).val()
    input_select = $(this)
    $.ajax(url: "/items/" + item_id, dataType: 'json').done (data) ->
      name = data.name
      description = data.description
      rate = parseFloat(data.unit_price).toFixed(2)
      quantity = 0
      input_select.closest('.panel').find('.panel-footer').text ''
      input_select.closest('.panel').find('.line_item_name').text name + ' (' + description + ')'
      input_select.closest('.panel').find('#item_description').val description
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
    
  ### Line item calculation field value changed ###
  $('.bill_input_fields_wrap').on 'keyup', '.amount-calculation-field', ->
    if $(this).is( "#bill_line_items__rate" )
      quantity = $(this).prevAll('#bill_line_items__quantity').first().val()
      rate = $(this).val()
      amount = (parseFloat(rate) * parseFloat(quantity)).toFixed(2)
      $(this).nextAll('#bill_line_items__amount').first().val amount
    if $(this).is( "#bill_line_items__gross" )
      gross = $(this).val()
      tare = $(this).nextAll('#bill_line_items__tare').first().val()
      rate = $(this).nextAll('#bill_line_items__rate').first().val()
      quantity = (parseFloat(gross) - parseFloat(tare))
      amount = (parseFloat(rate) * parseFloat(quantity)).toFixed(2)
      $(this).closest('.calculation_fields').nextAll('#quantity_preview').text "Net: " + quantity
      $(this).closest('.calculation_fields').nextAll('#unit_price_preview').text "Rate: " + "$" + rate
      $(this).nextAll('#bill_line_items__quantity').first().val quantity
      $(this).nextAll('#bill_line_items__amount').first().val amount
    if $(this).is( "#bill_line_items__tare" )
      gross = $(this).prevAll('#bill_line_items__gross').first().val()
      tare = $(this).val()
      rate = $(this).nextAll('#bill_line_items__rate').first().val()
      quantity = (parseFloat(gross) - parseFloat(tare))
      amount = (parseFloat(rate) * parseFloat(quantity)).toFixed(2)
      $(this).closest('.calculation_fields').nextAll('#quantity_preview').text "Net: " + quantity
      $(this).closest('.calculation_fields').nextAll('#unit_price_preview').text "Rate: " + "$" + rate
      $(this).nextAll('#bill_line_items__quantity').first().val quantity
      $(this).nextAll('#bill_line_items__amount').first().val amount
    if $(this).is( "#bill_line_items__quantity" )
      rate = $(this).nextAll('#bill_line_items__rate').first().val()
      quantity = $(this).val()
      amount = (parseFloat(rate) * parseFloat(quantity)).toFixed(2)
      $(this).nextAll('#bill_line_items__amount').first().val amount
    gross = $(this).closest('.panel').find('#bill_line_items__gross').val()
    tare = $(this).closest('.panel').find('#bill_line_items__tare').val()
    quantity = $(this).closest('.panel').find('#bill_line_items__quantity').val()
    description = $(this).closest('.panel').find('#item_description').val()
    rate = $(this).closest('.panel').find('#bill_line_items__rate').val()
    amount = $(this).closest('.panel').find('#bill_line_items__amount').val()
    $(this).closest('.panel').find('.panel-footer').text '(' + gross + ' - ' + tare + ') ' + '= ' + quantity + description + ' x '  + '$' + rate + ' = ' +  '$' + amount
    sum = 0;
    $('.amount').each ->
      sum += Number($(this).val())
      return
    $('#total').text '$' + sum.toFixed(2)
    return

  ### Re-enable disabled_with buttons for back button ###
  $(document).on 'page:change', ->
    $.rails.enableElement $('#bills_to_open')
    $.rails.enableElement $('#bills_to_paid')
    $('.pay_button').each ->
      $.rails.enableElement $(this)
      return
    return

  ### Start endless page stuff ###
  loading_bills = false
  $('a.load-more-bills').on 'inview', (e, visible) ->
    return if loading_bills or not visible
    loading_bills = true
    $('#spinner').show()
    $('a.load-more-bills').hide()

    $.getScript $(this).attr('href'), ->
      loading_bills = false
  ### End endless page stuff ###

  $ ->
    $('[data-toggle="popover"]').popover()
    return