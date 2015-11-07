# appmain.rb
require 'sinatra'
require './benchy'

set :benchy, Benchy.new("http://resttest.bench.co/transactions/")

get '/' do
  benchy = settings.benchy
  benchy.get_url
end
