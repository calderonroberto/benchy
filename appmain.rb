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

get '/balance' do
  benchy = settings.benchy
  benchy.get_data

  content_type :json
  {:balance => benchy.compute_balance}.to_json
end


get '/categories' do
  benchy = settings.benchy
  benchy.get_data

  content_type :json
  benchy.get_category_expenses.to_json
end

get '/balances' do
  benchy = settings.benchy
  benchy.get_data

  content_type :json
  benchy.get_daily_balances.to_json
end
