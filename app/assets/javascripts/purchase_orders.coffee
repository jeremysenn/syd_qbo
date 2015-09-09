# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

jQuery ->
  $(document).ready ->
    wrapper = $('.purchase_order_input_fields_wrap')
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
  $('#purchase_order_vendor').on 'change', ->
    input_select = $(this)
    panel = input_select.closest('.panel')
    name = input_select.closest('.panel').find($( "#purchase_order_vendor option:selected" )).text()
    #alert $(this).closest('.panel').find('.vendor_name').text $(this).text()
    input_select.closest('.panel').find('.vendor_name').text name
    panel.closest('.collapse').collapse('toggle')
    $(this).closest('.panel-collapse').collapse('hide')

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
      input_select.closest('.panel').find('.line_item_name').text name + ' (' + description + ')'
      input_select.closest('.panel').find('#item_description').val description
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
      quantity = (parseFloat(gross) - parseFloat(tare)).toFixed(0)
      $(this).nextAll('#purchase_order_line_items__quantity').first().val quantity
      amount = (parseFloat(rate) * parseFloat(quantity)).toFixed(2)
      $(this).nextAll('#purchase_order_line_items__amount').first().val amount
    if $(this).is( "#purchase_order_line_items__tare" )
      gross = $(this).prevAll('#purchase_order_line_items__gross').first().val()
      tare = $(this).val()
      rate = $(this).nextAll('#purchase_order_line_items__rate').first().val()
      quantity = (parseFloat(gross) - parseFloat(tare)).toFixed(0)
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
    description = $(this).closest('.panel').find('#item_description').val()
    rate = $(this).closest('.panel').find('#purchase_order_line_items__rate').val()
    amount = $(this).closest('.panel').find('#purchase_order_line_items__amount').val()
    $(this).closest('.panel').find('.panel-footer').text '(' + gross + ' - ' + tare + ') ' + '= ' + quantity + description + ' x '  + '$' + rate + ' = ' +  '$' + amount
    sum = 0;
    $('.amount').each ->
      sum += Number($(this).val())
      return
    $('#total').text '$' + sum.toFixed(2)
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

  ### Prettier file upload buttons ###
  $('input[type=file]').bootstrapFileInput()

  ### Picture Uploads ###
  $("#new_image_file").fileupload
    dataType: "script"
    disableImageResize: false
    imageMaxWidth: 1024
    imageMaxHeight: 768
    imageMinWidth: 800
    imageMinHeight: 600
    imageCrop: false

    add: (e, data) ->
      file = undefined
      types = undefined
      types = /(\.|\/)(gif|jpe?g|png|pdf)$/i
      file = data.files[0]
      if types.test(file.type) or types.test(file.name)
        data.context = $(tmpl("template-upload", file))
        current_data = $(this)
        data.process(->
          current_data.fileupload 'process', data
        ).done ->
          data.submit()
        #$("#new_image_file").prepend data.context
        #$('#new_image_file').append('<img src="' + URL.createObjectURL(data.files[0]) + '"/>')
        $('#pictures').prepend('<div class="row"><div class="col-xs-12 col-sm-4 col-md-4 col-lg-4"><div class="thumbnail"><img src="' + URL.createObjectURL(data.files[0]) + '"/></div></div></div>')
        #data.submit()
        $(".picture_loading_spinner").show()
        #$("#uploads").hide()
      else
        alert "" + file.name + " is not a gif, jpeg, or png picture file"

    progress: (e, data) ->
      if data.context
        progress = parseInt(data.loaded / data.total * 100, 10)
        data.context.find('.progress-bar').css('width', progress + '%')

  

  ### Check if any tares are zero ###
  $('#close_button').on 'click', (e) ->
    numZeroTare = 0
    $('.tare').each (index) ->
      if ($(this).val() == '0') || ($(this).val() == '')
        numZeroTare++
        return
      return
    if numZeroTare > 0
      confirm1 = confirm('You have empty or zero tare(s). Are you sure you want to close this ticket?')
      if confirm1
        return
      else
        e.preventDefault()
        return
      return
    return
    