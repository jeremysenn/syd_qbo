# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

jQuery ->
  wrapper = $('.bill_input_fields_wrap')
  $(wrapper).on 'click', '.remove_field', (e) ->
    #user click on item trash button
    if $('.line-item').length > 1
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

  ### Vendor value changed ###
  $('#bill_vendor').on 'change', ->
    input_select = $(this)
    vendor_id = input_select.val()
    panel = input_select.closest('.panel')
    name = input_select.closest('.panel').find($( "#bill_vendor option:selected" )).text()
    #input_select.closest('.panel').find('.vendor_name').text name
    panel.closest('.collapse').collapse('toggle')
    $(this).closest('.panel-collapse').collapse('hide')
    #input_select.closest('.panel').find('#edit_vendor_link').attr('href', "/vendors/" + vendor_id + "/edit"); 
    #input_select.closest('.panel').find('#edit_vendor_link').text name
    input_select.closest('.panel').find('#vendor_name').text name

  ### Line item changed ###
  $('.bill_input_fields_wrap').on 'change', 'select', ->
    item_id = $(this).val()
    input_select = $(this)
    $.ajax(url: "/items/" + item_id, dataType: 'json').done (data) ->
      name = data.name
      purchase_desc = data.purchase_desc
      rate = parseFloat(data.purchase_cost).toFixed(5)
      quantity = input_select.closest('.panel').find('#bill_line_items__quantity:first').val()
      input_select.closest('.panel').find('.calculation_details').text ''
      #input_select.closest('.panel').find('.panel-footer').text ''
      input_select.closest('.panel').find('.line_item_name').text name + ' (' + purchase_desc + ')'
      input_select.closest('.panel').find('#item_description').val purchase_desc

      input_select.closest('.panel').find('#bill_line_items__rate:first').val rate
      #input_select.closest('.panel').find('#bill_line_items__gross:first').val 0
      #input_select.closest('.panel').find('#bill_line_items__tare:first').val 0
      #input_select.closest('.panel').find('#bill_line_items__quantity:first').val 0
      amount = (parseFloat(rate) * parseFloat(quantity))
      input_select.closest('.panel').find('#bill_line_items__amount:first').val amount
      input_select.closest('.panel').find('#gross_picture_button:first').attr 'data-item-name', name 
      input_select.closest('.panel').find('#tare_picture_button:first').attr 'data-item-name', name
      input_select.closest('.panel').find('#gross_picture_button:first').attr 'data-item-id', item_id 
      input_select.closest('.panel').find('#tare_picture_button:first').attr 'data-item-id', item_id
      $('.amount-calculation-field').keyup()

      return
    
  ### Line item calculation field value changed ###
  $('.bill_input_fields_wrap').on 'keyup', '.amount-calculation-field', ->
    gross = $(this).closest('.panel').find('#bill_line_items__gross').val()
    tare = $(this).closest('.panel').find('#bill_line_items__tare').val()
    net = (parseFloat(gross) - parseFloat(tare)).toFixed(0)
    $(this).closest('.panel').find('#bill_line_items__quantity').val net
    $(this).closest('.panel').find('#gross_picture_button:first').attr 'data-weight', gross
    $(this).closest('.panel').find('#tare_picture_button:first').attr 'data-weight', tare

    description = $(this).closest('.panel').find('#item_description').val()
    rate = $(this).closest('.panel').find('#bill_line_items__rate').val()
    amount = (parseFloat(rate) * parseFloat(net)).toFixed(2)
    $(this).closest('.panel').find('#bill_line_items__amount').val amount

    #$(this).closest('.panel').find('.panel-footer').text '(' + gross + ' - ' + tare + ') ' + '= ' + net + description + ' x '  + '$' + rate + ' = ' +  '$' + amount
    $(this).closest('.panel').find('.calculation_details').text '(' + gross + ' - ' + tare + ') ' + '= ' + net + description + ' x '  + '$' + rate + ' = ' +  '$' + amount
    sum = 0;
    $('.amount').each ->
      sum += Number($(this).val())
      return
    $('#total').text '$' + sum.toFixed(2)
    return

  ### Re-enable disabled_with buttons for back button ###
  $(document).on 'page:change', ->
    $('.pay_button').each ->
      $.rails.enableElement $(this)
      return
    $('.bill_button').each ->
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

  $('html').on 'click', (e) ->
    if typeof $(e.target).data('original-title') == 'undefined' and !$(e.target).parents().is('.popover.in')
      $('[data-original-title]').popover 'hide'
    return

  ### Panel Collapse Links ###
  $(document).on 'click', '.bill_item_collapse_link', (e) ->
    $(this).closest('.panel').find('.collapse_icon').toggleClass('fa-check-square ')
    return