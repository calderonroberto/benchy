# appmain.rb
require 'sinatra'
require './benchy'
require 'json'

#set :benchy, Benchy.new("http://resttest.bench.co/transactions/")
set :benchy, Benchy.new("http://localhost/")

get '/transactions' do
  benchy = settings.benchy
  benchy.get_data

  content_type :json
  benchy.transactions.to_json
end
