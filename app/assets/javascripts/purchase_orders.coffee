# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

jQuery ->

  ### Delete of Commodity Items ###
  wrapper = $('.purchase_order_input_fields_wrap')
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
  ### End Delete of Commodity Items ###
  
  # Automatically highlight field value when focused
  $(wrapper).on 'click', '.amount-calculation-field', (e) ->
    $(this).select()
    return

  $('#new_ticket_navbar_link').on 'click', ->
    $(this).unbind('click')
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
    #input_select.closest('.panel').find('#edit_vendor_link').attr('href', "/vendors/" + vendor_id + "/edit"); 
    #input_select.closest('.panel').find('#edit_vendor_link').text name
    input_select.closest('.panel').find('#vendor_name').text name
  ### End vendor value changed ###

  ### Line item changed ###
  $('.purchase_order_input_fields_wrap').on 'change', 'select', ->
    item_id = $(this).val()
    input_select = $(this)
    $.ajax(url: "/items/" + item_id, dataType: 'json').done (data) ->
      name = data.name
      purchase_desc = data.purchase_desc
      rate = parseFloat(data.purchase_cost).toFixed(3)
      quantity = input_select.closest('.panel').find('#purchase_order_line_items__quantity:first').val()
      input_select.closest('.panel').find('.calculation_details').text ''
      #input_select.closest('.panel').find('.panel-footer').text ''
      #input_select.closest('.panel').find('.line_item_name').text name + ' (' + purchase_desc + ')'
      input_select.closest('.panel').find('.line_item_name').text name
      input_select.closest('.panel').find('#item_description').val purchase_desc

      input_select.closest('.panel').find('#purchase_order_line_items__rate:first').val rate
      #input_select.closest('.panel').find('#purchase_order_line_items__gross:first').val 0
      #input_select.closest('.panel').find('#purchase_order_line_items__tare:first').val 0
      #input_select.closest('.panel').find('#purchase_order_line_items__quantity:first').val 0
      amount = (parseFloat(rate) * parseFloat(quantity))
      input_select.closest('.panel').find('#purchase_order_line_items__amount:first').val amount
      input_select.closest('.panel').find('#gross_picture_button:first').attr 'data-item-name', name 
      input_select.closest('.panel').find('#tare_picture_button:first').attr 'data-item-name', name
      input_select.closest('.panel').find('#gross_picture_button:first').attr 'data-item-id', item_id 
      input_select.closest('.panel').find('#tare_picture_button:first').attr 'data-item-id', item_id
      input_select.closest('.panel').find('#gross_scale_button:first').attr 'data-item-name', name 
      input_select.closest('.panel').find('#tare_scale_button:first').attr 'data-item-name', name
      $('.amount-calculation-field').keyup()

      return
  ### End line item changed ###

  ### Line item calculation field value changed ###
  $('.purchase_order_input_fields_wrap').on 'keyup', '.amount-calculation-field', ->
    gross = $(this).closest('.panel').find('#purchase_order_line_items__gross').val()
    tare = $(this).closest('.panel').find('#purchase_order_line_items__tare').val()
    net = (parseFloat(gross) - parseFloat(tare)).toFixed(2)
    $(this).closest('.panel').find('#purchase_order_line_items__quantity').val net
    $(this).closest('.panel').find('#gross_picture_button:first').attr 'data-weight', gross
    $(this).closest('.panel').find('#tare_picture_button:first').attr 'data-weight', tare

    description = $(this).closest('.panel').find('#item_description').val()
    rate = $(this).closest('.panel').find('#purchase_order_line_items__rate').val()
    amount = (parseFloat(rate) * parseFloat(net)).toFixed(2)
    $(this).closest('.panel').find('#purchase_order_line_items__amount').val amount

    #$(this).closest('.panel').find('.panel-footer').text '(' + gross + ' - ' + tare + ') ' + '= ' + net + description + ' x '  + '$' + rate + ' = ' +  '$' + amount
    $(this).closest('.panel').find('.calculation_details').text '(' + gross + ' - ' + tare + ') ' + '= ' + net + description + ' x '  + '$' + rate + ' = ' +  '$' + amount
    sum = 0;
    $('.amount').each ->
      sum += Number($(this).val())
      return
    $('#total').text '$' + sum.toFixed(2)
    return
  ### End line item calculation field value changed ###

  ### Re-enable disabled_with buttons for back button ###
  $(document).on 'page:change', ->
    $('.purchase_order_button').each ->
      $.rails.enableElement $(this)
      return
    return
  ### End re-enable disabled_with buttons for back button ###

  ### Endless page stuff ###
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
  ### End event code changed - clear data; check if License Plate or VIN ###

  ### Gross/Tare Picture Uploads ###
  #$(document).on 'click', '.gross_or_tare_picture_button', ->
  $('.purchase_order_input_fields_wrap').on 'click', '.gross_or_tare_picture_button', ->
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
  ### End Gross/Tare Picture Uploads ###

  ### Clear the commodity picture upload fields for generic picture uploads ###
  $(document).on 'click', '#picture_upload_modal_link', ->
    $('#image_file_event_code').val ''
    $('#image_file_tare_seq_nbr').val ''
    $('#image_file_commodity_name').val ''
    $('#image_file_weight').val ''
    return
  ### End clear the commodity picture upload fields for generic picture uploads ###

  ### File upload ###
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
        $('#images').prepend('<div class="row"><div class="col-xs-12 col-sm-2 col-md-2 col-lg-2"><div class="thumbnail"><img src="' + URL.createObjectURL(data.files[0]) + '"/></div></div></div>')
        #data.submit()
        $(".picture_loading_spinner").show()
        #$("#uploads").hide()
      else
        alert "" + file.name + " is not a gif, jpeg, or png picture file"

    progress: (e, data) ->
      if data.context
        progress = parseInt(data.loaded / data.total * 100, 10)
        data.context.find('.progress-bar').css('width', progress + '%')
  ### End file upload ###

  ### Check if any tares are zero ###
  #$('#close_button, #close_and_pay_button').on 'click', (e) ->
  #  numZeroTare = 0
  #  $('.tare').each (index) ->
  #    if ($(this).val() == '0') || ($(this).val() == '')
  #      numZeroTare++
  #      return
  #    return
  #  if numZeroTare > 0
  #    alert 'You have empty or zero tare(s)'
      #confirm1 = confirm('You have empty or zero tare(s). Are you sure you want to close this ticket?')
      #if confirm1
      #  return
      #else
      #  e.preventDefault()
      #  return
  #    return
  #  return
  ### End check if any tares are zero ###

  ### Scale read and camera trigger ###
  #$(document).on 'click', '.scale_read_and_camera_trigger', (e) ->
  #$('.scale_read_and_camera_trigger').click ->
  $('#items_accordion').on 'click', '.scale_read_and_camera_trigger', (e) ->
    # Get data from scale button
    device_id = $(this).data( "device-id" )
    ticket_number = $(this).data( "ticket-number" )
    event_code = $(this).data( "event-code" )
    location = $(this).data( "location" )
    commodity_name = $(this).data( "item-name" )

    dashboard_icon = $(this).find( ".fa-dashboard" )
    dashboard_icon.hide()
    spinner_icon = $(this).find('.fa-spinner')
    spinner_icon.show()
    weight_text_field = $(this).closest('.input-group').find('.amount-calculation-field:first')
    weight = weight_text_field.val()

    # Make call to get the weight off the scale
    scale_read_ajax = ->
      $.ajax
        url: "/devices/" + device_id + "/scale_read"
        dataType: 'json'
        success: (data) ->
          weight = data.weight
          weight_text_field.val weight
          $('.purchase_order_input_fields_wrap .amount-calculation-field').trigger 'keyup'
          dashboard_icon.show()
          spinner_icon.hide()
          return
        error: ->
          dashboard_icon.show()
          spinner_icon.hide()
          #alert 'Error reading weight scale.'
          return

    # Make call to trigger scale camera
    camera_trigger_ajax = ->
      $.ajax
        url: "/devices/" + device_id + "/scale_camera_trigger"
        dataType: 'json'
        data:
          ticket_number: ticket_number
          event_code: event_code
          commodity_name: commodity_name
          location: location
          #weight: weight  
          weight: weight_text_field.val()
        success: (response) ->
          #alert 'Scale camera trigger successful.'
          return
        error: ->
          #alert 'Scale camera trigger failed'
          return

    # Kick off the scale read and camera trigger ajax calls
    scale_read_ajax().success camera_trigger_ajax
    e.preventDefault() # Don't hop to top of page due to anchor
  ### End scale read and camera trigger ###

  ### Scale camera trigger ###
  #$(document).on 'click', '.scale_camera_trigger', (e) ->
  #$('.scale_camera_trigger').click ->
  $('#items_accordion').on 'click', '.scale_camera_trigger', (e) ->
    # Get data from scale button
    device_id = $(this).data( "device-id" )
    ticket_number = $(this).data( "ticket-number" )
    event_code = $(this).data( "event-code" )
    location = $(this).data( "location" )
    commodity_name = $(this).data( "item-name" )

    camera_icon = $(this).find( ".fa-camera" )
    camera_icon.hide()
    spinner_icon = $(this).find('.fa-spinner')
    spinner_icon.show()
    weight_text_field = $(this).closest('.input-group').find('.amount-calculation-field:first')

    # Make call to trigger scale camera
    $.ajax
      url: "/devices/" + device_id + "/scale_camera_trigger"
      dataType: 'json'
      data:
        ticket_number: ticket_number
        event_code: event_code
        commodity_name: commodity_name
        location: location
        weight: weight_text_field.val()
      success: (response) ->
        camera_icon.show()
        spinner_icon.hide()
        #alert 'Scale camera trigger successful.'
        return
      error: ->
        camera_icon.show()
        spinner_icon.hide()
        #alert 'Scale camera trigger failed'
        return
    e.preventDefault() # Don't hop to top of page due to anchor
  ### End scale camera trigger ###

  ### TUD camera trigger ###
  $('#uploads').on 'click', '.tud_camera_trigger', ->
    # Get data from scale button
    device_id = $(this).data( "device-id" )
    ticket_number = $(this).data( "ticket-number" )
    event_code = this_event_code = $('#image_file_event_code').val()
    location = $(this).data( "location" )
    commodity_name = $(this).data( "item-name" )

    camera_icon = $(this).find( ".fa-camera" )
    camera_icon.hide()
    spinner_icon = $(this).find('.fa-spinner')
    spinner_icon.show()
    weight_text_field = $(this).closest('.input-group').find('.amount-calculation-field:first')

    # Make call to trigger scale camera
    $.ajax
      url: "/devices/" + device_id + "/scale_camera_trigger"
      dataType: 'json'
      data:
        ticket_number: ticket_number
        event_code: event_code
        commodity_name: commodity_name
        location: location
        weight: weight_text_field.val()
      success: (response) ->
        camera_icon.show()
        spinner_icon.hide()
        #alert 'Scale camera trigger successful.'
        return
      error: ->
        camera_icon.show()
        spinner_icon.hide()
        #alert 'Scale camera trigger failed'
        return
  ### End TUD camera trigger ###

  ### TUD signature pad ###
  #$(document).on 'click', '.tud_signature_pad', (e) ->
  $('.tud_signature_pad').click ->
    #e.preventDefault()
    # Get data from scale button
    device_id = $(this).data( "device-id" )
    ticket_number = $(this).data( "ticket-number" )
    company_id = $(this).data( "company-id" )

    pencil_icon = $(this).find( ".fa-pencil" )
    pencil_icon.hide()
    spinner_icon = $(this).find('.fa-spinner')
    spinner_icon.show()

    # Make call to trigger TUD signature pad
    $.ajax
      url: "/devices/" + device_id + "/get_signature"
      dataType: 'json'
      data:
        ticket_number: ticket_number
        company_id: company_id
      success: (response) ->
        pencil_icon.show()
        spinner_icon.hide()
        #alert 'Signature pad call successful.'
        return
      error: ->
        pencil_icon.show()
        spinner_icon.hide()
        #alert 'Signature pad call failed'
        return
  ### End TUD signature pad ###

  ### Finger print reader ###
  #$(document).on 'click', '.finger_print_trigger', (e) ->
  $('.finger_print_trigger').click ->
    #e.preventDefault()
    # Get data from button
    device_id = $(this).data( "device-id" )
    ticket_number = $(this).data( "ticket-number" )
    location = $(this).data( "company-id" )
    customer_name = $(this).data( "customer-name" )

    pointer_icon = $(this).find( ".fa-hand-pointer-o" )
    pointer_icon.hide()
    spinner_icon = $(this).find('.fa-spinner')
    spinner_icon.show()

    # Make call to trigger scale camera
    $.ajax
      url: "/devices/" + device_id + "/finger_print_trigger"
      dataType: 'json'
      data:
        ticket_number: ticket_number
        location: location
        customer_name: customer_name
      success: (response) ->
        pointer_icon.show()
        spinner_icon.hide()
        #alert 'Finger print trigger successful.'
        return
      error: ->
        pointer_icon.show()
        spinner_icon.hide()
        #alert 'Finger print trigger failed'
        return
  ### End finger print reader ###

  ### Scanner Trigger ###
  #$(document).on 'click', '.scanner_trigger', (e) ->
  $('.scanner_trigger').click ->
    #e.preventDefault()
    # Get data from button
    this_ticket_number = $(this).data( "ticket-number" )
    device_id = $(this).data( "device-id" )
    this_event_code = $('#image_file_event_code').val()
    this_location = $(this).data( "location" )
      
    spinner_icon = $(this).find('.fa-spinner')
    spinner_icon.show()

    # Make call to trigger scanner
    $.ajax
      url: "/devices/" + device_id + "/scanner_trigger"
      dataType: 'json'
      data:
        ticket_number: this_ticket_number
        event_code: this_event_code
        location: this_location
      success: (response) ->
        spinner_icon.hide()
        return
      error: ->
        spinner_icon.hide()
        alert 'Scanner trigger failed'
        return
  ### End Scanner Trigger ###

  ### Customer camera trigger ###
  $('.customer_camera_trigger_from_ticket').click ->
    # Get data from button
    this_vendor_id = $(this).data( "vendor-id" )
    #this_event_code = $('#image_file_event_code').val()
    this_location = $(this).data( "location" )
    this_camera_name = $(this).data( "camera-name" )
    if $('#vendor_given_name').length > 0
      this_given_name = $('#vendor_given_name').val()
    else
      this_given_name = $(this).data( "given-name" )
    if $('#vendor_family_name').length > 0
      this_family_name = $('#vendor_family_name').val()
    else
      this_family_name = $(this).data( "family-name" )
    camera_icon = $(this).find( ".fa-camera" )
    camera_icon.hide()
    spinner_icon = $(this).find('.fa-spinner')
    spinner_icon.show()

    # Make call to trigger customer camera
    $.ajax
      # url: "/devices/" + device_id + "/customer_camera_trigger"
      url: "/devices/customer_camera_trigger"
      dataType: 'json'
      data:
        customer_number: this_vendor_id
        customer_first_name: this_given_name
        customer_last_name: this_family_name
        event_code: 'Customer Photo'
        location: this_location
        camera_name: this_camera_name
      success: (response) ->
        spinner_icon.hide()
        camera_icon.show()
        #alert 'Customer camera trigger successful.'
        return
      error: ->
        spinner_icon.hide()
        #alert 'Customer camera trigger failed'
        return
  ### End customer camera trigger ###

  ### Bind tooltip to dynamically created elements ###
  $("body").tooltip({ selector: '[data-toggle="tooltip"]' })

  ### Panel Collapse Links ###
  $(document).on 'click', '.purchase_order_collapse_link', (e) ->
    $(this).closest('.panel').find('.collapse_icon').toggleClass('fa-check-square ')
    return