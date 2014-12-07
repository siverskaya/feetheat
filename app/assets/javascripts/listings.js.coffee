# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# Will be using CoffeeScript

# On page load, grab Stripe API key and connect to corresponding account from meta tags
jQuery ->
  Stripe.setPublishableKey($('meta[name="stripe-key"]').attr('content'))
  listing.setupForm()

# Only conditionally show bank account info forms on first new listing
listing =
  setupForm: ->
    $('#new_listing').submit ->
    	if $('input').length > 6
	        $('input[type=submit]').attr('disabled', true)
	        Stripe.bankAccount.createToken($('#new_listing'), listing.handleStripeResponse)
	        false

  
  # Error checking for invalid credit cards & logic for processing valid cards via Stripe
  handleStripeResponse: (status, response) ->
    if status == 200
      $('#new_listing').append($('<input type="hidden" name="stripeToken" />').val(response.id))
      $('#new_listing')[0].submit()
    else
      $('#stripe_error').text(response.error.message).show()
      $('input[type=submit]').attr('disabled', false)