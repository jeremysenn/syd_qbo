# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

jQuery ->

  ### Picture Uploads ###
  $("#new_cust_pic_file").fileupload
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
        $('#pictures').prepend('<div class="row"><div class="col-xs-12 col-sm-4 col-md-4 col-lg-4"><div class="thumbnail"><img src="' + URL.createObjectURL(data.files[0]) + '"/></div></div></div>')
        $('#cust_pics').prepend('<div class="row"><div class="col-xs-12 col-sm-4 col-md-4 col-lg-4"><div class="thumbnail"><img src="' + URL.createObjectURL(data.files[0]) + '"/></div></div></div>')
        $(".picture_loading_spinner").show()
      else
        alert "" + file.name + " is not a gif, jpeg, or png picture file"

    progress: (e, data) ->
      if data.context
        progress = parseInt(data.loaded / data.total * 100, 10)
        data.context.find('.progress-bar').css('width', progress + '%')

  ### Re-enable disabled_with buttons for back button ###
  $(document).on 'page:change', ->
    $.rails.enableElement $('#vendors_to_open')
    $.rails.enableElement $('#vendors_to_closed')
    $.rails.enableElement $('#vendors_to_paid')
    $('.vendor_button').each ->
      $.rails.enableElement $(this)
      return
    return

  ### Start endless page stuff ###
  loading_vendors = false
  $('a.load-more-vendors').on 'inview', (e, visible) ->
    return if loading_vendors or not visible
    loading_vendors = true
    $('#spinner').show()
    $('a.load-more-vendors').hide()

    $.getScript $(this).attr('href'), ->
      loading_vendors = false
  ### End endless page stuff ###

  $(document).on 'click', '.new_ticket_from_vendor', (e) ->
    $('#purchase_order_vendor').val $(this).attr 'data-vendor-id'
    $('#purchase_order_form').submit()
    return

  $('#drivers_license_scan').on 'click', ->
    device_id = $(this).data( "device-id" )
    drivers_license_scan_ajax = ->
      $.ajax
        url: "/devices/" + device_id + "/drivers_license_scan"
        dataType: 'json'
        success: (data) ->
          firstname = data.firstname
          lastname = data.lastname
          licensenumber = data.licensenumber
          dob = data.dob
          sex = data.sex
          issue_date = data.issue_date
          expiration_date = data.expiration_date
          streetaddress = data.streetaddress
          city = data.city
          state = data.state
          zip = data.zip
          $('#vendor_given_name').val firstname
          $('#vendor_family_name').val lastname
          $('#vendor_license_number').val licensenumber
          $('#vendor_dob').val dob
          $('#vendor_sex').val sex
          $('#vendor_license_issue_date').val issue_date
          $('#vendor_license_expiration_date').val expiration_date
          $('#vendor_billing_address_line1').val streetaddress
          $('#vendor_billing_address_city').val city
          $('#vendor_billing_address_country_sub_division_code').val state
          $('#vendor_billing_address_postal_code').val zip
          $('#spinner').hide()
          
          $('#scanned_license_picture').attr('src', 'http://qb.scrapyarddog.com/devices/' + device_id + '/show_scanned_jpeg_image')
          $('#scanned_license').show()

          return
        error: ->
          $('#spinner').hide()
          alert 'Error reading license.'
          return
    
    drivers_license_scan_ajax()
  
  # Save scanned image to jpegger automatically if it's visible when update vendor
  #$('#vendor_update_button').on 'click', ->
  #  if $('#scanned_license').is(':visible')
  #    $('#save_license_scan_to_jpegger').trigger 'click'
  #  return

  $('#vendor_form').submit (e) ->
    if $('#scanned_license').is(':visible')
      $('#save_license_scan_to_jpegger').trigger 'click'
    return

  $('#save_license_scan_to_jpegger').on 'click', ->
    device_id = $(this).data( "device-id" )
    vendor_id = $(this).data( "vendor-id" )
    location = $(this).data( "company-id" )
    save_license_scan_to_jpegger_ajax = ->
      $.ajax
        url: "/devices/" + device_id + "/drivers_license_camera_trigger"
        dataType: 'json'
        data:
          customer_first_name: $('#vendor_given_name').val()
          customer_last_name: $('#vendor_family_name').val()
          license_number: $('#vendor_license_number').val()
          dob: $('#vendor_dob').val()
          sex: $('#vendor_sex').val()
          license_issue_date: $('#vendor_license_issue_date').val()
          license_expiration_date: $('#vendor_license_expiration_date').val()
          customer_number: vendor_id
          event_code: "Photo ID"
          location: location
          address1: $('#vendor_billing_address_line1').val()
          city: $('#vendor_billing_address_city').val()
          state: $('#vendor_billing_address_country_sub_division_code').val()
          zip: $('#vendor_billing_address_postal_code').val()
        success: (data) ->
          # alert 'Saved scanned image to Jpegger.'
          return
        error: ->
          $('#spinner').hide()
          alert 'Error saving scanned image to Jpegger.'
          return
    
    save_license_scan_to_jpegger_ajax()

  # Force phone format
  $(".vendor_phone_field").mask("(999) 999-9999")