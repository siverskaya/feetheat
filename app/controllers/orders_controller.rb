class OrdersController < ApplicationController
  before_action :set_order, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!

  # Define /sales and /purchases such that all orders display in descending order for users
  def sales
    @orders = Order.all.where(seller: current_user).order("created_at DESC")
  end

  def purchases
    @orders = Order.all.where(buyer: current_user).order("created_at DESC")
  end

  # GET /orders/new
  def new
    @order = Order.new
    @listing = Listing.find(params[:listing_id])
  end

  # POST /orders
  # POST /orders.json
  def create
    @order = Order.new(order_params)
    @listing = Listing.find(params[:listing_id])
    @seller = @listing.user

    @order.listing_id = @listing.id
    @order.buyer_id = current_user.id
    @order.seller_id = @seller.id

    # Communicate our secret API key to Stripe to charge credit cards for our account
    Stripe.api_key = ENV["STRIPE_API_KEY"]
    token = params[:stripeToken]

    # Charge user's credit card, error checking to validate whether charge goes through
    begin
      charge = Stripe::Charge.create(
        :amount => (@listing.price * 100).floor, 
        :currency => "usd",
        :card => token
        )
      flash[:notice] = "Your order was successful. Thank you!"
    rescue Stripe::CardError => e
      flash[:danger] = e.message
    end

    transfer = Stripe::Transfer.create(
      :amount => (@listing.price * 95).floor,
      :currency => "usd",
      :recipient => @seller.recipient
      )


    respond_to do |format|
      if @order.save
        format.html { redirect_to root_url }
        format.json { render action: 'show', status: :created, location: @order }
      else
        format.html { render action: 'new' }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    def set_order
      @order = Order.find(params[:id])
    end

    def order_params
      params.require(:order).permit(:address, :city, :state)
    end
end
