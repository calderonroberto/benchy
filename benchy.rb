require 'net/http'
require 'json'

class Benchy

  def initialize(url)
    @url = url
    @data = []
  end

  def url()
    @url
  end

  def data()
    @data
  end


  ## Let's assume we want all the data.This function will paginate
  # until we load all the transactions specified by the API response.
  def get_data()

    totalCount = i = 1

    while @data.length < totalCount do

      res = Net::HTTP.get_response(URI(@url + i.to_s + '.json'))

      if res.code != '200' # safety first.
        break
      end

      begin
        res_data = JSON.parse(res.body)
        @data.concat(res_data['transactions'])
        totalCount = res_data['totalCount']
      rescue # deploy parachutes
        puts "Error getting data from the API, likely a JSON parse Error"
      end

      i+=1

    end

    @data #return data in case client needs it

  end

  # Let's compute our balance.

  def compute_balance


end
