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

  $('#new_ticket_navbar_link').on 'click', ->
    $('#purchase_order_form').submit()
    return

  ### Vendor value changed ###
  $('#purchase_order_vendor').on 'change', ->
    input_select = $(this)
    vendor_id = input_select.val()
    panel = input_select.closest('.panel')
    name = input_select.closest('.panel').find($( "#purchase_order_vendor option:selected" )).text()
    #input_select.closest('.panel').find('.vendor_name').text name
    panel.closest('.collapse').collapse('toggle')
    $(this).closest('.panel-collapse').collapse('hide')
    input_select.closest('.panel').find('#edit_vendor_link').attr('href', "/vendors/" + vendor_id + "/edit"); 
    input_select.closest('.panel').find('#edit_vendor_link').text name

  ### Line item changed ###
  $('.purchase_order_input_fields_wrap').on 'change', 'select', ->
    item_id = $(this).val()
    input_select = $(this)
    $.ajax(url: "/items/" + item_id, dataType: 'json').done (data) ->
      name = data.name
      description = data.description
      rate = parseFloat(data.purchase_cost).toFixed(2)
      quantity = 0
      input_select.closest('.panel').find('.panel-footer').text ''
      input_select.closest('.panel').find('.line_item_name').text name + ' (' + description + ')'
      input_select.closest('.panel').find('#item_description').val description

      input_select.closest('.panel').find('#purchase_order_line_items__rate:first').val rate
      input_select.closest('.panel').find('#purchase_order_line_items__gross:first').val 0
      input_select.closest('.panel').find('#purchase_order_line_items__tare:first').val 0
      input_select.closest('.panel').find('#purchase_order_line_items__quantity:first').val 0
      amount = (parseFloat(rate) * parseFloat(quantity))
      input_select.closest('.panel').find('#purchase_order_line_items__amount:first').val amount
      input_select.closest('.panel').find('#gross_picture_button:first').attr 'data-item-name', name 
      input_select.closest('.panel').find('#tare_picture_button:first').attr 'data-item-name', name
      input_select.closest('.panel').find('#gross_picture_button:first').attr 'data-item-id', item_id 
      input_select.closest('.panel').find('#tare_picture_button:first').attr 'data-item-id', item_id

      return

  ### Line item calculation field value changed ###
  $('.purchase_order_input_fields_wrap').on 'keyup', '.amount-calculation-field', ->
    gross = $(this).closest('.panel').find('#purchase_order_line_items__gross').val()
    tare = $(this).closest('.panel').find('#purchase_order_line_items__tare').val()
    net = (parseFloat(gross) - parseFloat(tare)).toFixed(0)
    $(this).closest('.panel').find('#purchase_order_line_items__quantity').val net
    $(this).closest('.panel').find('#gross_picture_button:first').attr 'data-weight', gross
    $(this).closest('.panel').find('#tare_picture_button:first').attr 'data-weight', tare

    description = $(this).closest('.panel').find('#item_description').val()
    rate = $(this).closest('.panel').find('#purchase_order_line_items__rate').val()
    amount = (parseFloat(rate) * parseFloat(net)).toFixed(2)
    $(this).closest('.panel').find('#purchase_order_line_items__amount').val amount

    $(this).closest('.panel').find('.panel-footer').text '(' + gross + ' - ' + tare + ') ' + '= ' + net + description + ' x '  + '$' + rate + ' = ' +  '$' + amount
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
    $.rails.enableElement $('#purchase_orders_to_vendors')
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

  ### Event code changed - clear data; check if License Plate or VIN ###
  $('#image_file_event_code').on 'change', ->
    $('#image_file_tare_seq_nbr').val ''
    $('#image_file_commodity_name').val ''
    $('#image_file_weight').val ''
    input_select = $(this)
    if input_select.val() == 'License Plate'
      $('#tag_form_group').show()
    else
      $('#tag_form_group').hide()
      $('#image_file_tag_number').val ''
    if input_select.val() == 'VIN'
      $('#vin_form_group').show()
    else
      $('#vin_form_group').hide()
      $('#image_file_vin_number').val ''
    return

  ### Picture Uploads ###
  $(document).on 'click', '.gross_or_tare_picture_button', ->
    event_code = $(this).data( "event-code" )
    item_id = $(this).data( "item-id" )
    item_name = $(this).data( "item-name" )
    weight = $(this).data( "weight" )

    $('#image_file_event_code').val event_code
    $('#image_file_tare_seq_nbr').val item_id
    $('#image_file_commodity_name').val item_name
    $('#image_file_weight').val weight

    $('input[type=file]').trigger 'click'
    false

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
        $('#images').prepend('<div class="row"><div class="col-xs-12 col-sm-4 col-md-4 col-lg-4"><div class="thumbnail"><img src="' + URL.createObjectURL(data.files[0]) + '"/></div></div></div>')
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

  $('.scale_read').on 'click', (e) ->
    e.preventDefault()
    dashboard_icon = $(this).find( ".fa-dashboard" )
    dashboard_icon.hide()
    spinner_icon = $(this).find('.fa-spinner')
    spinner_icon.show()
    weight_text_field = $(this).closest('.input-group').find('.amount-calculation-field:first')
    $.ajax(url: "/tud_devices/scale_read", dataType: 'json').done (data) ->
      dashboard_icon.show()
      spinner_icon.hide()
      weight = data.weight
      weight_text_field.val weight
      $('.purchase_order_input_fields_wrap .amount-calculation-field').trigger 'keyup'
      false