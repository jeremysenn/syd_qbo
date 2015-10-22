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
    $.ajax(url: "/tud_devices/drivers_license_scan", dataType: 'json').done (data) ->
      firstname = data.firstname
      lastname = data.lastname
      streetaddress = data.streetaddress
      city = data.city
      state = data.state
      zip = data.zip

      $('#vendor_given_name').val firstname
      $('#vendor_family_name').val lastname
      $('#vendor_billing_address_line1').val streetaddress
      $('#vendor_billing_address_city').val city
      $('#vendor_billing_address_country_sub_division_code').val state
      $('#vendor_billing_address_postal_code').val zip

      #$('#scanned_license_picture').attr('src', 'https://api.twilio.com/2010-04-01/Accounts/AC27c4bc7245c64b76ac92bac10c1cf9b0/Messages/MMe882fce1947ce6bb10e90ec0d3e5de3c/Media/ME2be55db848b4a1b43ec90bcd3dbbbd35');
      #$('#scanned_license_picture').attr('src', 'http://media.twiliocdn.com.s3-external-1.amazonaws.com/AC27c4bc7245c64b76ac92bac10c1cf9b0/c4afd7722eb694891bc02ec0013a6bb8');
      $('#scanned_license_picture').attr('src', 'http://192.168.111.150:10001')
      $('#scanned_license').show()

      $('#spinner').hide()