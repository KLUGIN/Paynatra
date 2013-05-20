require 'sinatra'
require 'stripe'
require 'pony'


set :publishable_key, ENV['PUBLISHABLE_KEY']
set :secret_key, ENV['SECRET_KEY']

Stripe.api_key = settings.secret_key

get '/' do
  erb :index
end

post '/charge' do
    @amount = params[:amount].to_f
    @amount = ( @amount * 100 )
    @amount = @amount.to_i
    @email = params[:email].to_s
    @cell = params[:mobilenumber].to_s if params[:mobilenumber]
    @invoice = params[:invoice]

    customer = Stripe::Customer.create(
      :email => @email,
      :card  => params[:stripeToken]
    )

    charge = Stripe::Charge.create(
      :amount      => @amount,
      :description => "Payment for #{params[:invoice]}",
      :currency    => 'usd',
      :customer    => customer
    )

  require 'googlevoiceapi'
  gvapi = GoogleVoice::Api.new(ENV['GV_EMAIL'], ENV['GV_PASS'])

  unless @cell.empty?
    gvapi.sms("1#{@cell}", "Thank you for your payment for invoice ##{params[:invoice]} of $#{ @amount/100.0 }. KLUGIN Development is always at your service." )
  end
    gvapi.sms(ENV['ADMIN_CELL'], "Hey boss! A payment for invoice ##{params[:invoice]} of $#{ @amount/100.0 } was just made!!!!!!!!! WOOHHOOO!!!" )

  erb :charge

end
