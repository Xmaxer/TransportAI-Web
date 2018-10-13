class BraintreeController < ApplicationController
  def client_token
    @gateway = Braintree::Gateway.new(
      environment: :sandbox,
      merchant_id: "s2w84n9y8wd4dkpm",
      public_key: "42gn5r2h5vkmd2fr",
      private_key: "88c96dfe47fc2633d083f8edb42dbff5"
    )
    if params[:customer_id]
      @client_token = @gateway.client_token.generate(
        customer_id: params[:customer_id]
      )
    else
      render 'braintree/invalid_customer_id'
    end
  end
  def checkout
    nonce_from_the_client = params[:payment_method_nonce]

    result = @gateway.transaction.sale(
      amount: params[:amount],
      payment_method_nonce: nonce_from_the_client
    )
  end
end
