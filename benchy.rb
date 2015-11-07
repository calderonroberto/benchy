require 'net/http'
require 'json'

class Benchy

  def initialize(url)
    @url = url
    @transactions = []
  end

  def url()
    @url
  end

  def transactions()
    @transactions
  end


  ## Let's assume we want all the data.This function will paginate
  # until we load all the transactions specified by the API response.
  def get_data()

    totalCount = i = 1

    while @transactions.length < totalCount do

      res = Net::HTTP.get_response(URI(@url + i.to_s + '.json'))

      if res.code != '200' # safety first.
        break
      end

      begin
        res_data = JSON.parse(res.body)
        @transactions.concat(res_data['transactions'])
        totalCount = res_data['totalCount']
      rescue # deploy parachutes
        puts "Error getting data from the API, likely a JSON parse Error"
      end

      i+=1

    end

    @transactions #return transactions in case client needs it

  end

  # Let's compute our balance.
  def compute_balance

    if @transactions.length == 0
      return 0 #probably better to return nil
    end

    @transactions.each  do |t|

    end


  end


end
