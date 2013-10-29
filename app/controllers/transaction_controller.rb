class TransactionController < ApplicationController
  #   def initialize(options = {})
  #       requires!(options, :login, :password)
  #       @cvv_enabled = options[:cvv_enabled]
  #       options = { :crypt_type => 7 }.merge(options)
  #   super
  # end

  def new
    @transaction = Transaction.new
  end

  def create
    
    @transaction = Transaction.new
    if @transaction.save
      # if the save for the picture was successful, go to index.html.erb
      redirect_to transactions_url 
    else
      # otherwise render the view associated with the action :new (i.e. new.html.erb)
      render :new
    end
  end

  def show
    @transaction = Transaction.find(params[:id])
  end

  def index
    @transactions = Transaction.all
    respond_to do |format|
    format.html {render :html => "/index"}
    format.json {render :json => @transactions.to_json}
    end
  end


  def process_transaction
  require 'active_merchant'

    ActiveMerchant::Billing::Base.mode = :test

    gateway = ActiveMerchant::Billing::MonerisGateway.new(
              :login => 'store5',
              :password => 'yesguy')
    # @transaction = Transaction.new
    # logger.info @transaction.inspect
    last_transaction = Transaction.all.last
    if last_transaction==nil
    order_id = "RyanShop1"
    else
    order_id = "RyanShop"+(last_transaction.id+1).to_s
    end

    # ActiveMerchant accepts all amounts as Integer values in cents
    amount = params[:amount_in_cents].to_i 
    credit_card = ActiveMerchant::Billing::CreditCard.new(
                  :first_name         => params[:firstname],
                  :last_name          => params[:lastname],
                  :number             => params[:credit_card],
                  :month              => params[:expiration_month],
                  :year               => params[:expiration_year],
                  :verification_value => params[:CVV])
    
    if credit_card.valid?
    # CAPTURE

    response = gateway.purchase(amount, credit_card, :order_id => order_id, :merchant => "Ryan")

      if response.success?
        logger.info response.inspect
        redirect_to "/transaction/new", :notice => "Successfully charged $#{sprintf("%.2f", amount / 100)} to the credit card #{credit_card.display_number}"
      else
        logger.info response.inspect
        redirect_to "/transaction/new", :alert => response.message
        # raise StandardError, response.message
      end
      build_transaction(credit_card,amount,response)
    else
      redirect_to "/transaction/new", :alert => "Invalid Credit Card"
    end


  end
  
  protected
  
  def build_transaction(credit_card,amount,response)
    new_transaction=Transaction.new 
    new_transaction.full_name = credit_card.first_name + " " + credit_card.last_name
    new_transaction.complete = response.params["complete"] 
    new_transaction.receipt_id = response.params["receipt_id"]
    new_transaction.reference_number = response.params["reference_num"]
    new_transaction.response_code = response.params["response_code"]
    new_transaction.auth_code = response.params["auth_code"]
    new_transaction.amount = response.params["trans_amount"]
    new_transaction.card_type = response.params["card_type"]
    new_transaction.moneris_id = response.params["trans_id"]
    new_transaction.save!

  end


end
